Genar ~ Beta_v1.0.0

Genar is a command-line software for generating installable android 
app versions of your website.


#   Documentation
    ===============================================================
1.  How To Setup.
    Current version of Genar supports only windows devices.
    Specifically win10+.
    -   Go to your Windows Settings and make sure `DEVELOPER_MODE` 
        is setup.

    -   Run `setup.exe` to init the setup process. This process 
        should be run once.

    If successful, a second run may mess up the existing setup.
    

2.  How To Generate App.
    Current version of Genar provides very limited configuration 
    input for an app generation.
    You can find the configuration values in the `gen_config.json` 
    file. Alter the values to
    your preference - in accordance to the appropriate format.
    Below are the current inputs.
    -   appName         =   String        = The name of your app.

    -   appIcon         =   String        = File name of your app.
                                            This file should exist 
                                            in the`gen_assets` 
                                            folder before running 
                                            the generate script.
                                            
    -   splashIcon      =   String        = File name of the icon 
                                            you want on your app's 
                                            splash screen. This 
                                            file should also exist 
                                            in the `gen_assets` 
                                            folder before running 
                                            the generate script.

    -   baseUrl         =   String        = The URL of your website. 
                                            This will be loaded as 
                                            the main activity of 
                                            your app when it launches.

    -   colorPrimary    =   String        = A 7-lenght-hex-string 
                                            value of your app's 
                                            primary color.
                                            Example is: #FFFFFF.

    -   colorAccent     =   String        = A 7-lenght-hex-string 
                                            value of your app's 
                                            accent color.
                                            Example is: #FFFFFF.

    -   pullToRefresh   =   boolean       = Whether or not to enable
                                            pull-to-refresh feature.
                                            Note: This feature is 
                                            still being perfected and
                                            may act buggy sometimes.

    Once values are set, save the updated `gen_config.json` and run
    the `generate.exe` script.
    Note: Your first generation after a successful setup will require
    internet access and ~2Gig data to patch up some setup processes.
    This will also take some time so be patient.
    Once first-time-generate is successful, next ones will be fast.


By Paa <paa.code.me@gmail.com> 2023.
