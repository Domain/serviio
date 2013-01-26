module org.serviio.licensing.LicenseValidator;

import java.lang.String;
import java.lang.Long;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import net.padlocksoftware.padlock.license.ImportException;
import net.padlocksoftware.padlock.license.License;
import net.padlocksoftware.padlock.license.LicenseIO;
import net.padlocksoftware.padlock.license.TestResult;
import net.padlocksoftware.padlock.validator.Validator;
import net.padlocksoftware.padlock.validator.ValidatorException;
import org.serviio.util.CollectionUtils;
import org.serviio.util.Tupple;
import org.serviio.licensing.LicenseProvider;
import org.serviio.licensing.ServiioLicense;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LicenseValidator
{
    private static immutable Logger log;
    private static const String publicKey = "308201b83082012c06072a8648ce3804013082011f02818100fd7f53811d75122952df4a9c2eece4e7f611b7523cef4400c31e3f80b6512669455d402251fb593d8d58fabfc5f5ba30f6cb9b556cd7813b801d346ff26660b76b9950a5a49f9fe8047b1022c24fbba9d7feb7c61bf83b57e7c6a8a6150f04fb83f6d3c51ec3023554135a169132f675f3ae2b61d72aeff22203199dd14801c70215009760508f15230bccb292b982a2eb840bf0581cf502818100f7e1a085d69b3ddecbbcab5c36b857b97994afbbfa3aea82f9574c0b3d0782675159578ebad4594fe67107108180b449167123e84c281613b7cf09328cc8a6e13c167a8b547c8d28e0a3ae1e2bb3a675916ea37f0bfa213562f1fb627a01243bcca4f1bea8519089a883dfe15ae59f06928b665e807b552564014c3bfecf492a0381850002818100aa6f608646fbb6fcf0af7eb335e6df115fc516625896178aea3f0aea36e53465ba052e5cc6cb17dda744b4a85d8bb94ac930366950bf308cf24de6f307d6118f21afdb42bdeaf852299a83163b06682934d9b7c92e273f8afe90adee2766fe5d28b222e04314a262001f33fbf17ed6397f491af934e0a6443286074c9427cd35";
    private LicenseProvider bundledLicenseProvider;
    private LicenseProvider customerLicenseProvider;
    private bool ignoreFloatTime = false;

    static this()
    {
        log = LoggerFactory.getLogger!(LicenseValidator)();
    }

    public this()
    {
        bundledLicenseProvider = new BundledLicenseProvider();
        customerLicenseProvider = new CustomerLicenseProvider();
    }

    ServiioLicense getCurrentLicense()
    {
        String customerLicensebody = customerLicenseProvider.readLicense();
        if (customerLicensebody is null)
        {
            return validateBundledLicense();
        }
        try
        {
            Tupple!(License, Long) customerLicense = validateLicense(customerLicensebody);
            return buildServiioLicense(customerLicense); 
        } 
        catch (InvalidLicenseException e) 
        {
            
        }
        return validateBundledLicense();
    }

    ServiioLicense validateProvidedLicense(String license)
    {
        Tupple!(License, Long) customerLicense = validateLicense(license);
        return buildServiioLicense(customerLicense);
    }

    private Tupple!(License, Long) validateLicense(String licenseBody)
    {
        if (licenseBody !is null) {
            log.debug_(String.format("Validating license file (%s bytes)", cast(Object[])[ Integer.valueOf(licenseBody.length()) ]));
            License l = null;
            try {
                l = LicenseIO.importLicense(licenseBody);

                Validator v = new Validator(l, publicKey);
                v.addPlugin(new VersionValidatorPlugin());
                v.setIgnoreFloatTime(ignoreFloatTime);
                v.validate();
                Long remainingMillis = v.getTimeRemaining(new Date());
                return new Tupple!(License, Long)(l, remainingMillis);
            } catch (IOException e) {
                throw new InvalidLicenseException("Couldn't load license: " + e.getMessage(), e);
            } catch (ImportException e) {
                throw new InvalidLicenseException("Invalid license: " + e.getMessage(), e);
            } catch (ValidatorException e) {
                throw new InvalidLicenseException("License failed validation these tests: " + getFailureDescription(e), e);
            }
            catch (Exception e) {
                throw new InvalidLicenseException("Couldn't load license because of unexpected exception: " + e.getMessage(), e);
            }
        }
        throw new InvalidLicenseException("License is empty");
    }

    private ServiioLicense validateBundledLicense() 
    {
        try {
            Tupple!(License, Long) bundledLicense = validateLicense(bundledLicenseProvider.readLicense());
            return buildServiioLicense(bundledLicense);
        } catch (InvalidLicenseException e) {
        }
        return ServiioLicense.FREE_LICENSE;
    }

    private String getFailureDescription(ValidatorException e)
    {
        List!(String) errors = new ArrayList!(String)();
        foreach (TestResult tr ; e.getLicenseState().getFailedTests()) {
            errors.add(tr.getResultDescription());
        }
        return CollectionUtils.listToCSV(errors, ",", true);
    }

    private ServiioLicense buildServiioLicense(Tupple!(License, Long) license) 
    {
        License lic = cast(License)license.getValueA();
        String id = lic.getProperty(LicenseProperties.ID.getName());
        String name = lic.getProperty(LicenseProperties.NAME.getName());
        String email = lic.getProperty(LicenseProperties.EMAIL.getName());
        String ver = lic.getProperty(LicenseProperties.VERSION.getName());
        LicensingManager.ServiioEdition edition = LicensingManager.ServiioEdition.valueOf(lic.getProperty(LicenseProperties.EDITION.getName()));
        LicensingManager.ServiioLicenseType type = LicensingManager.ServiioLicenseType.valueOf(lic.getProperty(LicenseProperties.TYPE.getName()));
        return new ServiioLicense(id, edition, type, name, email, ver, cast(Long)license.getValueB());
    }

    public void setBundledLicenseProvider(LicenseProvider bundledLicenseProvider)
    {
        this.bundledLicenseProvider = bundledLicenseProvider;
    }

    public void setCustomerLicenseProvider(LicenseProvider customerLicenseProvider) 
    {
        this.customerLicenseProvider = customerLicenseProvider;
    }

    public void setIgnoreFloatTime(bool ignoreFloatTime) 
    {
        this.ignoreFloatTime = ignoreFloatTime;
    }
}

/* Location:           D:\Program Files\Serviio\lib\serviio.jar
* Qualified Name:     org.serviio.licensing.LicenseValidator
* JD-Core Version:    0.6.2
*/