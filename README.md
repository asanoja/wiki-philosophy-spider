# wiki-philosophy-spider
Spider to verify that every term in Wikipedia is related to the Philosohy page.

It is a fun tool to create a tree of related concepts.

Input a term (in English) that corresponds to the path (without the /wiki) in the URL of a Wikipedia page.

For example:
'Ruby' or 'Information_extraction'

For 'Ruby' the spider clicks the first hyperlink found in the content area. Eventually it will land in the Phylosophy page.

There are some issues with disambiguation pages
Some loops can occurs. It is to solve in the future with more time ;)

PS: Sorry in advance!,  it was developed in 2011, so it uses still HPRICOT gem.

# Examples

$ ruby wikispider/wikispider.rb

Term: Ruby

Starting search for Ruby

1. Ruby
2. Gemstone
3. Crystal
4. Solid
5. State_of_matter#The_four_fundamental_states
6. Physics
7. Natural_science
8. Science
9. Knowledge
10. Fact
11. Evidence
12. Logical_assertion
13. Logic
14. Logical_form
15. Proposition
16. Analytic_philosophy
17. Philosophy

