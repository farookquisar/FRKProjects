create or replace PACKAGE device_categorizr
AS
   /******************************************************************************
      NAME:       categorizr
      PURPOSE:    detect web user agent device type

      Based on:
      Categorizr Version 1.1
      http://www.brettjankord.com/2012/01/16/categorizr-a-modern-device-detection-script/
      Written by Brett Jankord - Copyright (c) 2011

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      0.1        30-3-2012   crokitta         Created this package.
   ******************************************************************************/
   g_tablets_as_desktops   BOOLEAN := FALSE; --If TRUE, tablets will be categorized as desktops
   g_smarttv_as_desktops   BOOLEAN := FALSE; --If TRUE, smartTVs will be categorized as desktops
   g_user_agent            VARCHAR2 (2000); -- User Agent String used for detection
   g_device                VARCHAR2 (100);

   FUNCTION get_category
      RETURN VARCHAR2;

   FUNCTION isdesktop
      RETURN BOOLEAN;

   FUNCTION istablet
      RETURN BOOLEAN;

   FUNCTION istv
      RETURN BOOLEAN;

   FUNCTION ismobile
      RETURN BOOLEAN;

   /*
    The package is initialized automatically when called, trying to fetch the value of
    the HTTP_USER_AGENT, which naturally only succeeds when called through a web gateway.
    Additionally the package just offers a mean to test a user agent strings manually by
    passing the string with a procedure call
   */

   PROCEDURE set_user_agent (http_user_agent_string VARCHAR2 DEFAULT NULL);
END device_categorizr;
/

create or replace PACKAGE BODY device_categorizr
AS
   /******************************************************************************
      NAME:       categorizr
      PURPOSE:    detect web user agent device type

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      0.1        30-3-2012   crokitta         Created this package.
   ******************************************************************************/


   FUNCTION preg_match (pattern    VARCHAR2,
                        subject    VARCHAR2,
                        switch     VARCHAR2 DEFAULT NULL)
      RETURN BOOLEAN
   IS
      l_pattern   VARCHAR2 (32767) := pattern;
      l_subject   VARCHAR2 (32767) := subject;
   BEGIN
      IF LOWER (switch) = 'i'
      THEN
         l_pattern := LOWER (l_pattern);
         l_subject := LOWER (l_subject);
      END IF;

      IF REGEXP_INSTR (l_subject, l_pattern) = 0
      THEN
         RETURN FALSE;
      ELSE
         RETURN TRUE;
      END IF;
   END;

   PROCEDURE set_category
   IS
   BEGIN
      CASE
         -- Check if user agent is a smart TV - http://goo.gl/FocDk
         WHEN preg_match ('GoogleTV|SmartTV|Internet.TV|NetCast|NETTV|AppleTV|boxee|Kylo|Roku|DLNADOC|CE\-HTML', g_user_agent, 'i')
         THEN
            g_device := 'tv';
         -- Check if user agent is a TV Based Gaming Console
         WHEN preg_match ('Xbox|PLAYSTATION.3|Wii', g_user_agent, 'i')
         THEN
            g_device := 'tv';
         -- Check if user agent is a Tablet
         WHEN (preg_match ('iP(a|ro)d', g_user_agent, 'i')
               OR preg_match ('tablet|tsb_cloud_companion', g_user_agent, 'i'))
              AND (NOT preg_match ('RX-34', g_user_agent, 'i')
                   OR preg_match ('FOLIO', g_user_agent, 'i'))
         THEN
            g_device := 'tablet';
         -- Check if user agent is an Android Tablet
         WHEN preg_match ('Linux', g_user_agent, 'i')
              AND preg_match ('Android', g_user_agent, 'i')
              AND (NOT preg_match ('Fennec|mobi|HTC.Magic|HTCX06HT|Nexus.One|SC-02B|fone.945', g_user_agent, 'i')
               --or preg_match ('GT-P1000', g_user_agent, 'i')
               )
         THEN
            g_device := 'tablet';
         -- Check if user agent is a Kindle or Kindle Fire
         WHEN preg_match ('Kindle', g_user_agent, 'i')
              OR preg_match ('Mac.OS', g_user_agent, 'i')
                AND preg_match ('Silk', g_user_agent, 'i')
         THEN
            g_device := 'tablet';
         -- Check if user agent is a pre Android 3.0 Tablet
         WHEN preg_match (
                 'GT-P10|SC-01C|SHW-M180S|SGH-T849|SCH-I800|SHW-M180L|SPH-P100|SGH-I987|zt180|HTC(.Flyer|\_Flyer)|Sprint.ATP51|ViewPad7|pandigital(sprnova|nova)|Ideos.S7|Dell.Streak.7|Advent.Vega|A101IT|A70BHT|MID7015|Next2|nook',
                 g_user_agent,'i')
              OR preg_match ('MB511', g_user_agent, 'i')
                AND preg_match ('RUTEM', g_user_agent, 'i')
         THEN
            g_device := 'tablet';
         -- Check if user agent is unique Mobile User Agent
         WHEN preg_match ('BOLT|Fennec|Iris|Maemo|Minimo|Mobi|mowser|NetFront|Novarra|Prism|RX-34|Skyfire|Tear|XV6875|XV6975|Google.Wireless.Transcoder', g_user_agent, 'i')
         THEN
            g_device := 'mobile';
         -- Check if user agent is an odd Opera User Agent - http:--goo.gl/nK90K
         WHEN preg_match ('Opera', g_user_agent, 'i')
              AND preg_match ('Windows.NT.5', g_user_agent, 'i')
              AND preg_match ('HTC|Xda|Mini|Vario|SAMSUNG\-GT\-i8000|SAMSUNG\-SGH\-i9', g_user_agent, 'i')
         THEN
            g_device := 'mobile';
         -- Check if user agent is Windows Desktop
         WHEN preg_match ('Windows.(NT|XP|ME|9)', g_user_agent, 'i')
              AND NOT preg_match ('Phone', g_user_agent, 'i')
              OR preg_match ('Win(9|.9|NT)', g_user_agent, 'i')
         THEN
            g_device := 'desktop';
         -- Check if agent is Mac Desktop
         WHEN preg_match ('Macintosh|PowerPC', g_user_agent, 'i')
              AND NOT preg_match ('Silk', g_user_agent, 'i')
         THEN
            g_device := 'desktop';
         -- Check if user agent is a Linux Desktop
         WHEN preg_match ('Linux', g_user_agent, 'i')
              AND preg_match ('X11', g_user_agent, 'i')
         THEN
            g_device := 'desktop';
         -- Check if user agent is a Solaris, SunOS, BSD Desktop
         WHEN preg_match ('Solaris|SunOS|BSD', g_user_agent, 'i')
         THEN
            g_device := 'desktop';
         -- Check if user agent is a Desktop BOT/Crawler/Spider
         WHEN preg_match ('Bot|Crawler|Spider|Yahoo|ia_archiver|Covario-IDS|findlinks|DataparkSearch|larbin|Mediapartners-Google|NG-Search|Snappy|Teoma|Jeeves|TinEye', g_user_agent, 'i')
              AND NOT preg_match ('Mobile', g_user_agent, 'i')
         THEN
            g_device := 'desktop';
         -- Otherwise assume it is a Mobile Device
         ELSE
            g_device := 'mobile';
      END CASE;

      -- Categorize Tablets as desktops
      IF g_tablets_as_desktops
         AND g_device = 'tablet'
      THEN
         g_device := 'desktop';
      END IF;

      -- Categorize TVs as desktops
      IF g_smarttv_as_desktops
         AND g_device = 'tv'
      THEN
         g_device := 'desktop';
      END IF;
   END;

   PROCEDURE set_user_agent (http_user_agent_string VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      g_user_agent := http_user_agent_string;

      IF g_user_agent IS NULL
      THEN
         BEGIN
            g_user_agent := OWA_UTIL.get_cgi_env ('HTTP_USER_AGENT');
         EXCEPTION
            WHEN OTHERS
            THEN
               g_user_agent := NULL;
         END;
      END IF;

      set_category;
   EXCEPTION
      WHEN OTHERS
      THEN
         g_user_agent := null;
   END;

   FUNCTION get_category
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN g_device;
   END;

   -- Returns true if desktop user agent is detected
   FUNCTION isdesktop
      RETURN BOOLEAN
   IS
   BEGIN
      IF g_device = 'desktop'
      THEN
         RETURN TRUE;
      END IF;

      RETURN FALSE;
   END;

   -- Returns true if tablet user agent is detected
   FUNCTION istablet
      RETURN BOOLEAN
   IS
   BEGIN
      IF g_device = 'tablet'
      THEN
         RETURN TRUE;
      END IF;

      RETURN FALSE;
   END;

   -- Returns true if SmartTV user agent is detected
   FUNCTION istv
      RETURN BOOLEAN
   IS
   BEGIN
      IF g_device = 'tv'
      THEN
         RETURN TRUE;
      END IF;

      RETURN FALSE;
   END;

   -- Returns true if mobile user agent is detected
   FUNCTION ismobile
      RETURN BOOLEAN
   IS
   BEGIN
      IF g_device = 'mobile'
      THEN
         RETURN TRUE;
      END IF;

      RETURN FALSE;
   END;
BEGIN
   set_user_agent;
END device_categorizr;
