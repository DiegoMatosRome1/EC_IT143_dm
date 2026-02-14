
-- Q: How do I ensure "LastModifiedBy" reflects the original server login?
-- A: Use ORIGINAL_LOGIN() inside the trigger (already implemented with COALESCE).
SELECT SUSER_SNAME() AS SuserSname, ORIGINAL_LOGIN() AS OriginalLogin;
``
