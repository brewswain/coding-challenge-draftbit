-- Create your database tables here. Alternatively you may use an ORM
-- or whatever approach you prefer to initialize your database.
CREATE TABLE example_table (id SERIAL PRIMARY KEY, some_int INT, some_text TEXT);
INSERT INTO example_table (some_int, some_text) VALUES (123, 'hello');

CREATE TABLE dimensions (
  id SERIAL PRIMARY KEY,
  margin_top TEXT,
  margin_bottom TEXT,
  margin_left TEXT,
  margin_right TEXT,
  margin_top_unit TEXT,
  margin_bottom_unit TEXT,
  margin_left_unit TEXT,
  margin_right_unit TEXT,
  padding_top TEXT,
  padding_bottom TEXT,
  padding_left TEXT,
  padding_right TEXT,
  padding_top_unit TEXT,
  padding_bottom_unit TEXT,
  padding_left_unit TEXT,
  padding_right_unit TEXT
);