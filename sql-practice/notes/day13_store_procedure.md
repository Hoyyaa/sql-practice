# Day 13 (21/8): Store Procedure
## Kiến thức chính:
### Syntax
``` sql
CREATE OR REPLACE FUNCTION function_name(tham_so kieu_du_lieu)
RETURNS kieu_tra_ve
LANGUAGE plpgsql
[IMMUTABLE | STABLE | VOLATILE]
AS $$
DECLARE
    bien_cuc_bo kieu_du_lieu;
BEGIN
    -- logic
    RETURN gia_tri;
END;
$$;
```
### Biến, điều kiện:
```sql
DECLARE
    v_ten_bien kieu_du_lieu := gia_tri_mac_dinh;  -- optional default

IF dieu_kien THEN
    ...
ELSIF dieu_kien_khac THEN
    ...
ELSE
    ...
END IF;

SELECT cot1, cot2 INTO v_bien1, v_bien2
FROM bang WHERE dieu_kien;
IF NOT FOUND THEN
    -- không tìm thấy dòng nào
END IF;
```