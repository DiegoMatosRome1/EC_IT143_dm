
-- A: First name is the substring before the first space in ContactName.
-- Plan:
-- 1) LTRIM/RTRIM to normalize.
-- 2) CHARINDEX(' ') to locate first space; if none, return the whole value.
-- 3) Use LEFT() accordingly.
