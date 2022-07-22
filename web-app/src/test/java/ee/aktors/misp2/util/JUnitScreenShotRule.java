package ee.aktors.misp2.util;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Objects;

import org.junit.rules.MethodRule;
import org.junit.runners.model.FrameworkMethod;
import org.junit.runners.model.Statement;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.WebDriver;

public class JUnitScreenShotRule implements MethodRule {
    private WebDriver driver;
    private final Path saveFolder;

    public JUnitScreenShotRule() {
        this.saveFolder = Objects.requireNonNull(Paths.get(System.getProperty("it.screenshots")), "System property 'it.screenshots' not set");
        try {
            // Try to create the target folder in case it does not exist
            // Constructor throws IOException if this fails
            Files.createDirectory(saveFolder);
        } catch (Exception e) {
            System.err.println("Error setting up JUnitScreenShotRule");
            e.printStackTrace(System.err);
        }
    }

	@Override
	public Statement apply(Statement baseStatement, FrameworkMethod method, Object target) {
        return new Statement() {

			@Override
			public void evaluate() throws Throwable {
			    try {
                    baseStatement.evaluate();
                } catch(Throwable t) {
                    final Path screenshotPath = Paths.get(saveFolder.toString(), String.format("screenshot-%s.png", method.getName()));
                    final File screenshotFile = ((TakesScreenshot)driver).getScreenshotAs(OutputType.FILE);
                    Files.copy(screenshotFile.toPath(), screenshotPath, StandardCopyOption.REPLACE_EXISTING);
                    System.out.println("Wrote failure screenshot to " + screenshotPath.toString());
                    throw t;
                }	
                finally {
                    driver.quit();
                }
			}

        };
	}

    // Can't set this in the driver since it is initially null
    public void setDriver(WebDriver driver) {
        this.driver = driver;
    }

}
