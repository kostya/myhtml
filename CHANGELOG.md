## 1.5.0 (2019-12-26)
* added Myhtml::SAX parser, see examples/sax_links*.cr
* updated libmodest to 4c03bfc

## 1.4.2 (2019-06-04)
* better Node#inspect
* better Collection#inspect
* minor improvements

## 1.4.1 (2019-05-05)
* fix doctype printing in to_pretty_html

## 1.4.0 (2019-03-10)
* update modest lib
* add Node#to_pretty_html

## 1.3.0 (2019-01-02)
* all lib errors now raise LibError
* parser.css by default search from document node, not from root
* create_node works with more tag_id types
* decode_html_entities optimize, not to create temp parser

## 1.2.0 (2018-10-07)
* Internal refactor: Split Parser and Tree
* Add Tree#create_node, Node#append_child, Node#insert_before, Node#insert_after, thanks: @edwardloveall
* Add Node#inner_text=
* Add example: create_html.cr

## 1.1.0 (2018-09-23)
* Add Myhtml::Parser#to_html, fixed #11
* Update Modest to last revision
* Cleanups, refactors

## 1.0.0 (2018-08-04)
* Merge myhtml v0.30 with modest v0.17
