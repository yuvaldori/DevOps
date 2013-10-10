import com.atlassian.jira.rest.client.JiraRestClient;
import com.atlassian.jira.rest.client.NullProgressMonitor;
import com.atlassian.jira.rest.client.domain.*;
import com.atlassian.jira.rest.client.domain.input.FieldInput;
import com.atlassian.jira.rest.client.domain.input.TransitionInput;
import com.atlassian.jira.rest.client.internal.jersey.JerseyJiraRestClientFactory;
import org.codehaus.jackson.JsonParseException;
import org.codehaus.jackson.map.ObjectMapper;
import org.codehaus.jackson.type.TypeReference;
import org.codehaus.jettison.json.JSONArray;
import org.codehaus.jettison.json.JSONException;
import org.codehaus.jettison.json.JSONObject;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.*;

/**
 * User: nirb
 * Date: 5/27/13
 */
public class JiraClient {

    private JiraRestClient jiraClient;
    private NullProgressMonitor pm;

    private Set<String> openspacesComponents;
    private Set<String> serverComponents;
    private Set<String> serviceGridComponents;
    private Set<String> cppComponents;
    private Set<String> dotNetComponents;
    private Set<String> adminAndUitComponents;
    private Set<String> platforms;




    public JiraClient(String user, String password) throws URISyntaxException {

        initComponents();

        final JerseyJiraRestClientFactory factory = new JerseyJiraRestClientFactory();
        final URI jiraServerUri = new URI("https://gigaspaces.atlassian.net");
        jiraClient = factory.createWithBasicHttpAuthentication(jiraServerUri, user, password);
        pm = new NullProgressMonitor();
    }

    public JiraRestClient getJiraClient() {
        return jiraClient;
    }

    public SearchResult createFilter(String jqlQuery){
        return jiraClient.getSearchClient().searchJql(jqlQuery, pm);
    }

    public Set<Issue> getIssuesFromFilter(SearchResult filter){

        Set<Issue> issues = new HashSet<Issue>();

        for(BasicIssue issue : filter.getIssues()){
            Issue result = jiraClient.getIssueClient().getIssue(issue.getKey(), pm);
            issues.add(result);
        }

        return issues;
    }

    public String createJqlQuery(String issueProject, String issueType, String issueResolution, String issueStatus, String issueFixVersion, String sprintNumber, String createdAfter){

        StringBuilder query = new StringBuilder();
        query.append("project = " + issueProject);

        if(issueType != null && !issueType.isEmpty()){
            query.append(" AND issuetype in (" + issueType + ")");
        }
        if(issueResolution != null && !issueResolution.isEmpty()){
            query.append(" AND resolution in (" + issueResolution + ")");
        }
        if(issueStatus != null && !issueStatus.isEmpty()){
            query.append(" AND status in (" + issueStatus + ")");
        }
        if(issueFixVersion != null && !issueFixVersion.isEmpty()){
            query.append(" AND fixVersion in (\"" + issueFixVersion + "\")");
        }
        if(sprintNumber != null && !sprintNumber.isEmpty()){
            query.append(" AND sprint in (" + sprintNumber + ")");
        }
        if(createdAfter != null && !createdAfter.isEmpty()){
            query.append(" AND created >= " + createdAfter);
        }

        return query.toString();

    }

    public String platformsIterableToToString(ObjectMapper mapper, Issue issue) throws JSONException, IOException {
        String result = "";
        JSONArray platforms = (JSONArray) issue.getFieldByName("Platform").getValue();
        if(platforms == null)
            return "";
        for(int i = 0; i < platforms.length(); i++){
            result+=mapper.readValue(platforms.get(i).toString(), Map.class).get("value") + ",";
        }
        if(result.lastIndexOf(",") == result.length()-1){
            result = result.substring(0, result.length()-1);
        }
        return result;
    }

    public String salesforceIdIterableToToString(Issue issue){
        if(issue.getFieldByName("SalesForce Case ID") == null)
            return "";
        String id = (String) issue.getFieldByName("SalesForce Case ID").getValue();
        if(id != null){
            return id +"";
        }
        return "";
    }

    public String fixVersionIterableToToString(Issue issue) throws JSONException, IOException {
        String result = "";
        for(Version version : issue.getFixVersions()){
            result += version.getName() + ",";
        }
        if(result.lastIndexOf(",") == result.length()-1){
            result = result.substring(0, result.length()-1);
        }
        return result;
    }

    public boolean isPublicIssue(ObjectMapper mapper, Issue issue) throws JSONException, IOException {
        JSONObject platforms = (JSONObject) issue.getFieldByName("Security Level").getValue();
        if(mapper.readValue(platforms.toString(), Map.class).get("name").equals("Public"))
            return true;
        else
            return false;
    }



    public String componentsIterableToString(Iterable<BasicComponent> iterable){

        StringBuilder res = new StringBuilder();

        for(BasicComponent component : iterable){
            res = res.append("," + component.getName());
        }

        return res.substring(1);
    }

    public String getSectionFromIssue(Issue issue){

        for(BasicComponent component : issue.getComponents()){

            String componentName = component.getName();

            if(serverComponents.contains(componentName)){
                if(issue.getIssueType().getName().contains("Bug")){
                    return "API, Proxy, Server, External Data Source";
                }
                else{
                    return "API, Proxy, Server";
                }
            }
            if(openspacesComponents.contains(componentName)){
                return "OpenSpaces";
            }
            if(serviceGridComponents.contains(componentName)){
                return "Service Grid";
            }
            if(cppComponents.contains(componentName)){
                if(issue.getIssueType().getName().contains("Bug")){
                    return "C++";
                }
                else{
                    return "C++ Specifics";
                }
            }
            if(dotNetComponents.contains(componentName)){
                if(issue.getIssueType().getName().contains("Bug")){
                    return ".NET";
                }
                else{
                    return ".NET Specifics";
                }
            }
            if(adminAndUitComponents.contains(componentName)){
                return "Configuration, UI, CLI & Admin tools";
            }
        }

        return "";
    }

    private void initComponents(){

        openspacesComponents = new HashSet<String>();
        serverComponents = new HashSet<String>();
        serviceGridComponents = new HashSet<String>();
        cppComponents = new HashSet<String>();
        dotNetComponents = new HashSet<String>();
        adminAndUitComponents = new HashSet<String>();
        platforms = new HashSet<String>();

        openspacesComponents.add("Elastic PU");
        openspacesComponents.add("ESB");
        openspacesComponents.add("JEE API/Integ.");
        openspacesComponents.add("OpenSpaces");
        openspacesComponents.add("Web Container Integration");
        serverComponents.add("LRMI");
        serverComponents.add("API");
        serverComponents.add("EDS");
        serverComponents.add("Engine");
        serverComponents.add("Events");
        serverComponents.add("JPA");
        serverComponents.add("LRMI");
        serverComponents.add("Mirror");
        serverComponents.add("Persistency");
        serverComponents.add("Proxy");
        serverComponents.add("Replication");
        serverComponents.add("Security");
        serverComponents.add("SQL Query");
        serverComponents.add("WAN");
        serverComponents.add("Security");
        serviceGridComponents.add("Jini");
        serviceGridComponents.add("Service Grid");
        cppComponents.add("C++");
        dotNetComponents.add(".NET");
        adminAndUitComponents.add("GS-UI");
        adminAndUitComponents.add("Configuration");
        adminAndUitComponents.add("Admin Tools");
        adminAndUitComponents.add("Logging");
        adminAndUitComponents.add("Maven");
        adminAndUitComponents.add("Packages");
        adminAndUitComponents.add("Web-UI");

        platforms.add("All");
        platforms.add("Java");
        platforms.add(".NET");
        platforms.add("C++");
    }


//    public static void main(String[] args) throws URISyntaxException, JSONException, IOException {
//        final JerseyJiraRestClientFactory factory = new JerseyJiraRestClientFactory();
//        final URI jiraServerUri = new URI("https://gigaspaces.atlassian.net");
//        final JiraRestClient jiraClient = factory.createWithBasicHttpAuthentication(jiraServerUri, "xxx", "xxxx");
//        final NullProgressMonitor pm = new NullProgressMonitor();
//
//        SearchResult filter = jiraClient.getSearchClient().searchJql("project = GS AND issuetype = Bug AND key = GS-11315", pm);
//        ObjectMapper mapper = new ObjectMapper();
//        for(BasicIssue issue : filter.getIssues()){
//            Issue result = jiraClient.getIssueClient().getIssue(issue.getKey(), pm);
//                JSONArray platforms = (JSONArray) result.getFieldByName("Platform").getValue();
//                for(int i = 0; i < platforms.length(); i++){
//                    System.out.println(mapper.readValue(platforms.get(i).toString(), Map.class).get("value"));
//                }
//
//
//        }

//        //now let's vote for it
//        jiraClient.getIssueClient().vote(issue.getVotesUri(), pm);
//
//        // now let's watch it
//        jiraClient.getIssueClient().watch(issue.getWatchers().getSelf(), pm);
//
//        // now let's start progress on this issue
//        final Iterable<Transition> transitions = jiraClient.getIssueClient().getTransitions(issue.getTransitionsUri(), pm);
//        final Transition startProgressTransition = getTransitionByName(transitions, "Start Progress");
//        jiraClient.getIssueClient().transition(issue.getTransitionsUri(), new TransitionInput(startProgressTransition.getId()), pm);
//
//        // and now let's resolve it as Incomplete
//        final Transition resolveIssueTransition = getTransitionByName(transitions, "Resolve Issue");
//        Collection<FieldInput> fieldInputs = Arrays.asList(new FieldInput("resolution", "Incomplete"));
//        final TransitionInput transitionInput = new TransitionInput(resolveIssueTransition.getId(), fieldInputs, Comment.valueOf("My comment"));
//        jiraClient.getIssueClient().transition(issue.getTransitionsUri(), transitionInput, pm);

//    }

//    private static Transition getTransitionByName(Iterable<Transition> transitions, String transitionName) {
//        for (Transition transition : transitions) {
//            if (transition.getName().equals(transitionName)) {
//                return transition;
//            }
//        }
//        return null;
//    }
}

