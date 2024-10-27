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
-- Since this demo assumes only one set of dimensions, we'll pre-make a single row. Otherwise, we'd just make an api call to create a new row.
INSERT INTO dimensions (margin_top,
  margin_bottom,
  margin_left,
  margin_right,
  margin_top_unit,
  margin_bottom_unit,
  margin_left_unit,
  margin_right_unit,
  padding_top,
  padding_bottom,
  padding_left,
  padding_right,
  padding_top_unit,
  padding_bottom_unit,
  padding_left_unit,
  padding_right_unit ) VALUES ('auto', 'auto', 'auto', 'auto', 'px', 'px', 'px', 'px', 'auto', 'auto', 'auto', 'auto', 'px', 'px', 'px', 'px');