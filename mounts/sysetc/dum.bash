thestring="a
a
a
a
b
b
c
c
c
c
"
thestring=(
a
a
a
a
b
b
c
c
c
c
	)
echo "grep for all 'a' entries"
echo "$(grep -o 'a' <<< "${thestring[@]}")"
echo "count all 'a' entries"
echo "$(grep -o 'a' <<< "${thestring[@]}" | wc -l)"
echo "get a string of unique entries"
#echo "$(uniq <<< ${thestring[@]})"
#echo "$(printf "%s\n" "${thestring[@]}" | uniq)"
mapfile -t the_unique_ones < <(printf "%s\n" "${thestring[@]}" | sort -u)
echo "there are ${#the_unique_ones[@]} unique entries:"
echo "${the_unique_ones[@]}"
