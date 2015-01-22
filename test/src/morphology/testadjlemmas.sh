# Kommando når man er i sme: sh test/src/morphology/testadjlemmas.sh
# Dette skriptet tester at nesten alle lemmaene i adjectives.lexc kan genereres. De som ikke kan genereres, kopieres til missingadjLemmas.txt

# Hent ut lemmaer, bortsett fra utkommmenterte (^\!),  dem med hardkoding for spesielle former (K), LexSub (som blir filtrert bort fra normgenerator), adjektiver som bare har attributtform (ATTR|Attr| At ) , adjektiver som krever tagger for komparering (BBO |MUS |BUOREMUSS|OVDDIT |STUORIBUS|BUStem) og lemmaer som bare opptrer i sammensetninger (FINJU|Rreal | R) Lemmaene lagres som adjs
grep ";" $GTHOME/langs/sme/src/morphology/stems/adjectives.lexc | grep -v "^\!" | egrep -v "(LEXICON|ATTR|FINJU|Der|Attr| At |BBO |MUS |BUOREMUSS|OVDDIT |STUORIBUS|BUStem | K | Rreal | R |LexSub)" | sed 's/% /€/g' | sed 's/%:/¢/g' |  tr ":+" " " | cut -d " " -f1 | tr -d "%" | tr "€" " " | tr "¢" ":" | sort -u > adjs

# generer former med +A+Sg+Nom (grunnformen for de fleste). Lagres som analadjs
cat adjs | sed 's/$/+A+Sg+Nom/' | $LOOKUP $GTHOME/langs/sme/src/generator-gt-norm.xfst | cut -f2 | grep -v "A+" | grep -v "^$" | sort -u > analadjs 

# Hent ut lemmaer for plurale lemmaer (_PL). Lemmaene lagres som pluradjs
grep ";" $GTHOME/langs/sme/src/morphology/stems/adjectives.lexc | grep -v "^\!" | grep -v "+Gen" | grep -v LexSub | grep "_PL " | tr ":+" " " | cut -d " " -f1 | tr -d "%" | sort -u > pluradjs

# generer former med +A+Pl+Nom for plurale lemmaer. Lagres i analadjs
cat pluradjs | sed 's/$/+A+Pl+Nom/' | $LOOKUP $GTHOME/langs/sme/src/generator-gt-norm.xfst | cut -f2 | grep -v "A+" | grep -v "^$" | sort -u >> analadjs 

# Hent ut lemmaer som bare har attributtform. Lagres i attradjs
grep ";" $GTHOME/langs/sme/src/morphology/stems/adjectives.lexc | grep -v "^\!" | grep -v "+Gen" | grep -v LexSub | egrep "(ATTR|Attr)" | sed 's/% /€/g' | sed 's/%:/¢/g' |  tr ":+" " " | cut -d " " -f1 | tr -d "%" | tr "€" " " | tr "¢" ":" | sort -u > attradjs

# generer former med +A+Attr lemmaer som bare har attributtform. Lagres i analadjs
cat attradjs | sed 's/$/+A+Attr/' | $LOOKUP $GTHOME/langs/sme/src/generator-gt-norm.xfst | cut -f2 | grep -v "A+" | grep -v "^$" | sort -u >> analadjs 

# Hent ut lemmaer som krever superlativtagg. Lagres i superladjs
grep ";" $GTHOME/langs/sme/src/morphology/stems/adjectives.lexc | grep -v "^\!" | grep "BUOREMUSS" | grep -v LexSub | tr ":+" " " | cut -d " " -f1 | tr -d "%" | sort -u > superladjs

# generer former for lemmaer lemmaer som krever superlativtagg, med +A+Superl+Sg+Nom. Lagres i analadjs
cat superladjs | sed 's/$/+A+Superl+Sg+Nom/' | $LOOKUP $GTHOME/langs/sme/src/generator-gt-norm.xfst | cut -f2 | grep -v "A+" | grep -v "^$" | sort -u >> analadjs 

# Hent ut lemmaer som krever komparativtagg. Lagres i compladjs
grep ";" $GTHOME/langs/sme/src/morphology/stems/adjectives.lexc | grep -v "^\!" | egrep "(OVDDIT|BBO |BU/MUS|EABBO/EAMOS|STUORIBUS|BUStem)" | grep -v LexSub | tr ":+" " " | cut -d " " -f1 | tr -d "%" | sort -u > compladjs

# generer former for lemmaer lemmaer som krever komparativtagg, med +A+Comp+Sg+Nom. Lagres i analadjs
cat compladjs | sed 's/$/+A+Comp+Sg+Nom/' | $LOOKUP $GTHOME/langs/sme/src/generator-gt-norm.xfst | cut -f2 | grep -v "A+" | grep -v "^$" | sort -u >> analadjs 

# Samle alle lemmaer i en fil, sorter, unifiser
cat attradjs compladjs superladjs >> adjs
sort -u -o adjs adjs 

# Samle alle genererte former i en fil, sorter, unifiser
sort -u -o analadjs analadjs 

# Sammenlikne lista med adjektivlemmaer med den genererte lista med adjektiver. Formene som er i adjektivlemmalista, men ikke i den genererte lista, kopieres til missingadjLemmas.txt. 
comm -23 adjs analadjs | grep -v '^$' | sed 's/$/+A+Sg+Nom/' | $LOOKUP $GTHOME/langs/sme/src/generator-gt-norm.xfst > $GTHOME/langs/sme/test/data/missingadjLemmas.txt

# Fjerne lister
rm *adjs

# Åpne fila i see
see $GTHOME/langs/sme/test/data/missingadjLemmas.txt
