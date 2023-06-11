{ lib
, mkChromiumDerivation
}:

mkChromiumDerivation (base: {
  name = "chromium-driver";
  packageName = "chromium";
  buildTargets = [ "chromedriver" ];

  outputs = [ "out" ];

  installPhase = ''
    mkdir $out
    ls -al "$buildPath"
    cp -rv "$buildPath" $out
  '';

  meta = {
    description = "An open source web browser from Google";
    longDescription = ''
      WebDriver is an open source tool for automated testing of webapps across
      many browsers. It provides capabilities for navigating to web pages, user
      input, JavaScript execution, and more. ChromeDriver is a standalone
      server that implements the W3C WebDriver standard.
    '';
    homepage = "https://chromedriver.chromium.org/";
    maintainers = with lib.maintainers; [ amarshall ];
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    mainProgram = "chromedriver";
    # hydraPlatforms = lib.optionals (channel == "stable" || channel == "ungoogled-chromium") ["aarch64-linux" "x86_64-linux"];
  };
})
