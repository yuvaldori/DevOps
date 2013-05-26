import iTests.framework.utils.IOUtils;
import org.apache.commons.io.FileUtils;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;
import org.openqa.selenium.support.PageFactory;
import webui.tests.SeleniumDriverFactory;

import java.io.File;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

/**
 * User: nirb
 * Date: 5/21/13
 */
public class EarlyAccessUpdate {

    public static void updateWiki() throws Exception {

        SeleniumDriverFactory sdf = new SeleniumDriverFactory();
        sdf.setDriverType(SeleniumDriverFactory.DriverType.CHROME);
        sdf.setChromeDriverPath("file:///" + getRootDir() + "/src/main/resources/chromedriver.exe");

        Properties props = getPropertiesFromPropsFile();
        String rootUrl = props.getProperty("url");
        sdf.setRootUrl(rootUrl);
        sdf.init();
        sdf.getDriver().get(rootUrl);

        Page p = PageFactory.initElements(sdf.getDriver(), Page.class );
        p.login(props.getProperty("user"),props.getProperty("password"));
        MarkupPage markupPage = PageFactory.initElements(sdf.getDriver(), MarkupPage.class);

        File tempWikiTextFile = new File(getRootDir() + "/src/main/resources/wiki-text.txt");
        String wikiText = markupPage.getText();
        int startIndex = wikiText.indexOf("h2");
        String currentVersionTextBlock = wikiText.substring(startIndex, wikiText.indexOf("h2", startIndex + 1));

        FileUtils.writeStringToFile(tempWikiTextFile, wikiText);
        Map<String, String> replaceTextMap = new HashMap<String, String>();
        replaceTextMap.put(props.getProperty("old-milestone"), props.getProperty("new-milestone"));
        replaceTextMap.put(props.getProperty("old-milestone").toUpperCase(), props.getProperty("new-milestone").toUpperCase());
        replaceTextMap.put(props.getProperty("old-build-number"), props.getProperty("new-build-number"));
        IOUtils.replaceTextInFile(tempWikiTextFile, replaceTextMap);

        String deckOpenning = "{deck:id=previous}";
        String cardOpenning = "{card:labal=" + props.getProperty("build-version") + " " + props.getProperty("old-milestone").toUpperCase() + "}";
        String cardClose = "{card}";

        replaceTextMap.clear();
        replaceTextMap.put(deckOpenning, deckOpenning + "\n\n" + cardOpenning + "\n" + currentVersionTextBlock + "\n" + cardClose);
        IOUtils.replaceTextInFile(tempWikiTextFile, replaceTextMap);

        String newText = FileUtils.readFileToString(tempWikiTextFile);

        markupPage.writeNewText(newText);

        markupPage.save();

        FileUtils.deleteQuietly(tempWikiTextFile);
        sdf.quit();
    }

    public static void main(String[] args) throws Exception {

        //args
        String user = args[0];
        String password = args[1];
        String oldMilestone = args[2];
        String newMilestone = args[3];
        String oldBuildNumber = args[4];
        String newBuildNumber = args[5];

        File propertiesFile = new File(getRootDir() + "/src/main/resources/wiki_update.properties");
        String backupPath = IOUtils.backupFile(propertiesFile.getPath());

        Map<String, String> replaceMap = new HashMap<String, String>();
        replaceMap.put("USER", user);
        replaceMap.put("PASSWORD", password);
        replaceMap.put("OLD_MILESTONE", oldMilestone);
        replaceMap.put("NEW_MILESTONE", newMilestone);
        replaceMap.put("OLD_BUILD_NUMBER", oldBuildNumber);
        replaceMap.put("NEW_BUILD_NUMBER", newBuildNumber);
        IOUtils.replaceTextInFile(propertiesFile, replaceMap);

        updateWiki();

        FileUtils.deleteQuietly(propertiesFile);
        FileUtils.moveFile(new File(backupPath), propertiesFile);
    }

    public static class MarkupPage {
        public WebElement markupTextarea;

        @FindBy(css=".submit-buttons.bottom input[name='cancel']")
        public WebElement cancelButton;

        @FindBy(css=".submit-buttons.bottom input[name='confirm']")
        public WebElement saveButton;

        public void clear(){
            markupTextarea.click();
            markupTextarea.clear();
        }

        public String getText(){
            return markupTextarea.getText();
        }

        public void writeNewText(String text){
            markupTextarea.clear();
            markupTextarea.sendKeys(text);
        }

        public void cancel(){
            cancelButton.click();
        }

        public void save(){
            saveButton.click();
        }
    }

    public static class Page{

        @FindBy(name = "os_username")
        public WebElement username;

        @FindBy(name = "os_password")
        public WebElement password;

        public WebElement loginButton;

        public void login(String username, String password ){
            this.username.sendKeys(username);
            this.password.sendKeys(password);
            loginButton.click();
        }

    }

    private static Properties getPropertiesFromPropsFile() {

        File propsFile = new File(getRootDir() + "/src/main/resources/wiki_update.properties");
        Properties props;
        try {
            props = IOUtils.readPropertiesFromFile(propsFile);
        } catch (final Exception e) {
            throw new IllegalStateException("Failed reading properties file : " + e.getMessage());
        }
        return props;
    }

    private static String getRootDir(){
        return new File(".").getAbsolutePath();
    }




}
