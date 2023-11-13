# 29.08.2023

I will first download the fire origin data. Go to the link [https://discover.data.vic.gov.au/dataset/fire-origins-current-and-historical5](https://discover.data.vic.gov.au/dataset/fire-origins-current-and-historical5) and select Explore on the SHP file and then Click add to cart and then when downloading form the cart use GDA2020 as the projection. Apparently Australia is moving 7cms every year and since 1994 (GDA94) the difference is 1.8 metres. So I created an account and I made the order and I got an email from them.

The downloaded shp file was only 1MB which is suspicious.

So there was an issue installing units.

```
configure: error: in `/private/var/folders/_0/xq33thxs0673s355c51w2g580000gn/T/Rtmpdpaxwt/R.INSTALL6e8764a5dfa4/units':
configure: error: 
--------------------------------------------------------------------------------
  Configuration failed because libudunits2.so was not found. Try installing:
    * deb: libudunits2-dev (Debian, Ubuntu, ...)
    * rpm: udunits2-devel (Fedora, EPEL, ...)
    * brew: udunits (OSX)
  If udunits2 is already installed in a non-standard location, use:
    --configure-args='--with-udunits2-lib=/usr/local/lib'
  if the library was not found, and/or:
    --configure-args='--with-udunits2-include=/usr/include/udunits2'
  if the header was not found, replacing paths with appropriate values.
  You can alternatively set UDUNITS2_INCLUDE and UDUNITS2_LIBS manually.
--------------------------------------------------------------------------------
```

Fixed the above with
```
Sys.setenv("UDUNITS2_INCLUDE" =  "/opt/homebrew/include")
Sys.setenv("UDUNITS2_LIBS" =  "/opt/homebrew/lib")
```

# 06.09.2023

It's the day before the meeting and it's sad that we are doing these things now. But I have faith that we will pull through. 

I was able to get the X and Y coordinates for the data but the bushfires with the accurate points are only from 2019 onwards.

The forest data has not been updated since 2018 and therefore we can use it as it is. Patrick has imported the `z001001.adf` file for some reason. I will inspect each of these files and see why.

While installing weatherOz there was an error with imagemagick.

```
imagemagick@6 is keg-only, which means it was not symlinked into /opt/homebrew,
because this is an alternate version of another formula.

If you need to have imagemagick@6 first in your PATH, run:
  echo 'export PATH="/opt/homebrew/opt/imagemagick@6/bin:$PATH"' >> ~/.zshrc

For compilers to find imagemagick@6 you may need to set:
  export LDFLAGS="-L/opt/homebrew/opt/imagemagick@6/lib"
  export CPPFLAGS="-I/opt/homebrew/opt/imagemagick@6/include"

For pkg-config to find imagemagick@6 you may need to set:
  export PKG_CONFIG_PATH="/opt/homebrew/opt/imagemagick@6/lib/pkgconfig"
```

weatherOz has data mostly for western australia
Check https://weather.agric.wa.gov.au/

# 02.10.2023

Coming back to this project after a long time of not looking at it.

