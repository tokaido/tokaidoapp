certs = `security find-certificate -a -p /System/Library/Keychains/SystemRootCertificates.keychain`
certificates = certs.scan(/-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----/m,)

certificates.select do |c|
  IO.popen("openssl x509 -inform pem -checkend 0 -noout >/dev/null", "w") do |openssl|
    openssl.write(c)
    openssl.close_write
  end

  $?.success?
end

File.write("cert.pem", certificates.join("\n") << "\n")
