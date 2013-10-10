import com.atlassian.jira.rest.client.domain.Issue;
import com.atlassian.jira.rest.client.domain.SearchResult;
import org.codehaus.jackson.map.ObjectMapper;
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

        ObjectMapper mapper = new ObjectMapper();

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
        String[] cards = {"{card:label=Known Issues & Limitations}", "{card:label=Fixed Issues}", "{card:label=New Features and Improvements}"};
        String[] headlines = {
                "{card:label=Known Issues & Limitations}\n" +
                        "|| Key || Summary || SalesForce ID || Since version || Workaround || Platform/s ||",
                "{card:label=Fixed Issues}\n" +
                        "|| Key || Summary || Fixed in Version || SalesForce ID || Platform/s ||",
                "{card:label=New Features and Improvements}\n" +
                        "|| Key || Summary || Since Version || SalesForce ID || Documentation Link || Platform/s ||"
        };
        int headlineIndex = 0;
        for(String card : cards){
            int cardStartIndex = pageContent.indexOf(headlines[headlineIndex]);
            int cardEndIndex = pageContent.indexOf("\n{card}", cardStartIndex);
            String cardSubstring = pageContent.substring(cardStartIndex + headlines[headlineIndex].length(), cardEndIndex);
            pageContent = pageContent.replace(cardSubstring, "");
            headlineIndex++;
        }

        for(int i = 0; i < 3; i++){

            //Fixed issues
            if(i == 0){
                issueType = "Bug";
                issueResolution = "Fixed";
                issueStatus = "Closed";
                issueFixVersion = tempIssueFixVersion;
                createdAfter = "";
            }
            //New features
            if(i == 1){
                issueType = "\"New Feature\", Task, Improvement, Sub-task";
                issueResolution = "Fixed";
                issueStatus = "Closed";
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

            for(Issue issue : issuesFromFilter){
                String fieldsText;
                String newEntryText;
                if(!jiraClient.isPublicIssue(mapper, issue)){
                    continue;
                }
                if(issueType.contains("Bug")){
                    if(issueResolution.contains("Unresolved")){
                        fieldsText =   "{card:label=Known Issues & Limitations}\n" +
                                "|| Key || Summary || SalesForce ID || Since version || Workaround || Platform/s ||";
                        newEntryText = "| " + issue.getKey() + " | " + issue.getSummary() + " | " +jiraClient.salesforceIdIterableToToString(issue) + " | " + sinceVersion + " | | " + jiraClient.platformsIterableToToString(mapper, issue) + " |";
                    }
                    else{
                        fieldsText = "{card:label=Fixed Issues}\n" +
                                "|| Key || Summary || Fixed in Version || SalesForce ID || Platform/s ||";
                        newEntryText = "| " + issue.getKey() + " | " + issue.getSummary() + " | " + jiraClient.fixVersionIterableToToString(issue) + " | " + jiraClient.salesforceIdIterableToToString(issue) + " | " + jiraClient.platformsIterableToToString(mapper, issue) + " |";
                    }
                }
                else{
                    fieldsText = "{card:label=New Features and Improvements}\n" +
                            "|| Key || Summary || Since Version || SalesForce ID || Documentation Link || Platform/s ||";
                    newEntryText = "| " + issue.getKey() + " | " + issue.getSummary() + " | " + jiraClient.fixVersionIterableToToString(issue) + " | " + jiraClient.salesforceIdIterableToToString(issue) +" | | " + jiraClient.platformsIterableToToString(mapper, issue) + " |";
                }

                int cardStartIndex = pageContent.indexOf(fieldsText);
                String cardSubstring = pageContent.substring(cardStartIndex, cardStartIndex + fieldsText.length());

                String newCardSubstring;
                String newText = fieldsText + "\n" + newEntryText;
                newCardSubstring = cardSubstring.replace(fieldsText, newText);
                pageContent = pageContent.replace(cardSubstring, newCardSubstring);
                page.setContent(pageContent);
            }
        }
        wikiClient.getConfluenceSOAPService().storePage(wikiClient.getToken(), page);
    }
}
