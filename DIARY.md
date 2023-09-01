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
