import org.swift.common.soap.confluence.ConfluenceSoapService;
import org.swift.common.soap.confluence.ConfluenceSoapServiceServiceLocator;

/**
 * User: nirb
 * Date: 5/26/13
 */
public class WikiClient {
    private final ConfluenceSoapServiceServiceLocator fConfluenceSoapServiceGetter = new ConfluenceSoapServiceServiceLocator();
    private ConfluenceSoapService fConfluenceSoapService = null;
    private String fToken = null;


    public WikiClient(String server, String user, String pass) throws Exception {
        try {
            String endPoint = "/rpc/soap-axis/confluenceservice-v1";
            fConfluenceSoapServiceGetter.setConfluenceserviceV2EndpointAddress(server + endPoint);
            fConfluenceSoapServiceGetter.setMaintainSession(true);
            fConfluenceSoapService = fConfluenceSoapServiceGetter.getConfluenceserviceV2();
            fToken = fConfluenceSoapService.login(user, pass);
        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }
    }

    public String getToken() {
        return fToken;
    }

    public ConfluenceSoapService getConfluenceSOAPService() {
        return fConfluenceSoapService;
    }
}
