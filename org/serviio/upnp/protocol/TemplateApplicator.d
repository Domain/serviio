module org.serviio.upnp.protocol.TemplateApplicator;

import freemarker.tmpl.Configuration;
import freemarker.tmpl.DefaultObjectWrapper;
import freemarker.tmpl.Template;
import freemarker.tmpl.TemplateException;
import java.lang.String;
import java.io.IOException;
import java.io.StringWriter;
import java.io.Writer;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TemplateApplicator
{
  private static immutable Logger log = LoggerFactory.getLogger!(TemplateApplicator)();

  private static Configuration cfg = new Configuration();

  public static String applyTemplate(String templateName, Map!(String, Object) parameters)
  {
    try
    {
      Template temp = cfg.getTemplate(templateName);
      Writer out_ = new StringWriter();
      temp.process(parameters, out_);
      out_.flush();
      return out_.toString();
    }
    catch (IOException e) {
      log.error(String.format("Cannot find template %s", cast(Object[])[ templateName ]), e);
      return null;
    }
    catch (TemplateException e) {
      log.error(String.format("Error processing template %s: %s", cast(Object[])[ templateName, e.getMessage() ]), e);
    }return null;
  }

  static this()
  {
    try
    {
      cfg.setClassForTemplateLoading(TemplateApplicator.class_, "/");

      cfg.setObjectWrapper(new DefaultObjectWrapper());
      cfg.setOutputEncoding("UTF-8");
      cfg.setURLEscapingCharset(null);
    } catch (Exception e) {
      log.error("Cannot initialize Freemarker engine", e);
    }
  }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
 * Qualified Name:     org.serviio.upnp.protocol.TemplateApplicator
 * JD-Core Version:    0.6.2
 */