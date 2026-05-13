-- 1. Atomic Serial Number Generation using a sequence
CREATE SEQUENCE family_serial_seq;

CREATE OR REPLACE FUNCTION generate_family_serial()
RETURNS text AS $$
DECLARE
  next_val int;
BEGIN
  SELECT nextval('family_serial_seq') INTO next_val;
  RETURN 'FAM-' || LPAD(next_val::text, 4, '0');
END;
$$ LANGUAGE plpgsql;

-- 2. Atomic Operator Entry Count Increment
CREATE OR REPLACE FUNCTION increment_operator_count(operator_id uuid)
RETURNS void AS $$
BEGIN
  UPDATE operators
  SET entries_count = entries_count + 1
  WHERE id = operator_id;
END;
$$ LANGUAGE plpgsql;
