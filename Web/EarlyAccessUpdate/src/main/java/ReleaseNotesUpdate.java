import com.atlassian.jira.rest.client.domain.Issue;
import com.atlassian.jira.rest.client.domain.SearchResult;
import org.swift.common.soap.confluence.ConfluenceSoapService;
import org.swift.common.soap.confluence.RemotePage;
import org.swift.common.soap.confluence.RemoteServerInfo;

import java.util.Set;

/**
 * User: nirb
 * Date: 5/27/13
 */
public class ReleaseNotesUpdate {

    public static void main(String[] args) throws Exception {

        String jiraUser = args[0];
        String jiraPassword = args[1];
        String wikiUser= args[2];
        String wikiPassword = args[3];
        String issueProject = args[4];
        String issueFixVersion = args[5];
        String sprintNumber = args[6];
        String createdAfter = args[7];
        String buildVersion = args[8];
        String sinceVersion = args[9];

        JiraClient jiraClient = new JiraClient(jiraUser, jiraPassword);
        String issueType = "";
        String issueResolution = "";
        String issueStatus = "";

        String tempCreatedAfter = createdAfter;
        String tempIssueFixVersion = issueFixVersion;

        for(int i = 0; i < 3; i++){

            // Fixed issues
            if(i == 0){
                issueType = "Bug";
                issueResolution = "Fixed";
                issueStatus = "Resolved,Closed";
                issueFixVersion = tempIssueFixVersion;
                createdAfter = "";
            }

            //New features
            if(i == 1){
                issueType = "\"New Feature\", Task, Improvement, Sub-task";
                issueResolution = "Fixed";
                issueStatus = "Resolved,Closed";
                issueFixVersion = tempIssueFixVersion;
                createdAfter = "";
            }

            //Known issues
            if(i == 2){
                issueType = "Bug";
                issueResolution = "Unresolved";
                issueStatus = "";
                issueFixVersion = "";
                createdAfter = tempCreatedAfter;
            }

            String jqlQuery = jiraClient.createJqlQuery(issueProject, issueType, issueResolution, issueStatus, issueFixVersion, sprintNumber, createdAfter);
            System.out.println("query: " + jqlQuery);
            SearchResult filter = jiraClient.createFilter(jqlQuery);
            Set<Issue> issuesFromFilter = jiraClient.getIssuesFromFilter(filter);

            WikiClient wikiClient = new WikiClient("http://wiki.gigaspaces.com/wiki", wikiUser, wikiPassword);

            System.out.println("Connected ok.");
            ConfluenceSoapService service = wikiClient.getConfluenceSOAPService();
            String token = wikiClient.getToken();

            RemoteServerInfo info = service.getServerInfo(token);
            System.out.println("Confluence version: " + info.getMajorVersion() + "." + info.getMinorVersion());
            System.out.println("Completed.");

            String cutBuildVersion = buildVersion.substring(0, buildVersion.length()-1);
            String pageTitle = "GigaSpaces XAP " + cutBuildVersion + "X Release Notes";

            RemotePage page = service.getPage(token, "RN", pageTitle);
            String pageContent = page.getContent();

            for(Issue issue : issuesFromFilter){

                String cardName;
                String fieldsText;
                String regexFieldsText;
                String newEntryText;

                if(issueType.contains("Bug")){
                    if(issueResolution.contains("Unresolved")){
                        cardName = "Known Issues & Limitations";
                        regexFieldsText = "Key(.*)Summary(.*)SalesForce ID(.*)Since version(.*)Fixed in version(.*)Workaround(.*)Component/s";
                        fieldsText = "|| Key || Summary || SalesForce ID || Since version || Fixed in version || Workaround || Component/s ||";
                        newEntryText = "| " + issue.getKey() + " | " + issue.getSummary() + " | | " + sinceVersion + " | | | " + jiraClient.componentsIterableToString(issue.getComponents()) + " |";
                    }
                    else{
                        cardName = "Fixed Issues";
                        regexFieldsText = "Key(.*)Summary(.*)Since Version(.*)SalesForce ID(.*)Component/s";
                        fieldsText = "|| Key || Summary || Since Version || SalesForce ID || Component/s ||";
                        newEntryText = "| " + issue.getKey() + " | " + issue.getSummary() + " | " + sinceVersion + " | | " + jiraClient.componentsIterableToString(issue.getComponents()) + " |";
                    }
                }
                else{
                    cardName = "New Features and Improvements";
                    regexFieldsText = "Key(.*)Summary(.*)Since Version(.*)SalesForce ID(.*)Documentation Link(.*)Component/s";
                    fieldsText = "|| Key || Summary || Since Version || SalesForce ID || Documentation Link || Component/s ||";
                    newEntryText = "| " + issue.getKey() + " | " + issue.getSummary() + " | " + sinceVersion + " | | | " + jiraClient.componentsIterableToString(issue.getComponents()) + " |";
                }

                int carsStartIndex = pageContent.indexOf(cardName);
                int cardEndIndex = pageContent.indexOf("{card}", carsStartIndex);
                String cardSubstring = pageContent.substring(carsStartIndex, cardEndIndex);
                String newCardSubstring;

                String matchingSectionName = jiraClient.getSectionFromIssue(issue);
                if(matchingSectionName.isEmpty()){
                    System.err.println("the components of issue " + issue.getKey() + " are invalid. It was not updated.");
                    continue;
                }

                int sectionStartIndex = cardSubstring.indexOf(matchingSectionName);
                int sectionEndIndex = (matchingSectionName.contains("UI")) ? cardSubstring.indexOf("{toc-zone}") : cardSubstring.indexOf("h2", sectionStartIndex);
                String sectionSubstring = cardSubstring.substring(sectionStartIndex, sectionEndIndex);
                String newSectionSubstring;

                String originalText = "(?s)" + matchingSectionName + "(.*)" + regexFieldsText;
                String newText = matchingSectionName + "\n\n" + fieldsText + "\n" + newEntryText;
                newSectionSubstring = sectionSubstring.replaceAll(originalText, newText);
                newCardSubstring = cardSubstring.replace(sectionSubstring, newSectionSubstring);
                pageContent = pageContent.replace(cardSubstring, newCardSubstring);

                page.setContent(pageContent);
            }

            wikiClient.getConfluenceSOAPService().storePage(wikiClient.getToken(), page);
        }
    }
}
