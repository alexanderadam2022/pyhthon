#!/bin/bash
## This application helps you to download and save the images of a valid website address you entered.

_current_label="entry"

getURL_function(){
echo "Enter a valid URL:"
read URL  # get URL input
VALID='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'  
# string='http://www.google.com/test/link.php'

if [[ $URL =~ $VALID ]]; then 
    echo "Valid URL:$URL."
	_current_label="done"
else
    echo "Invalid URL!!!"
   _current_label="invalid"
fi
}

while [ "$_current_label" != "done" ];
do
  getURL_function ; 
done


_current_label="entry"
getDIRPATH_function(){
# Write down the correct path of your local directory to save the images downloaded.   
echo "Enter image download directory: [ $PWD/downloads ] for default press Enter"
read DIRPATH # get DIRPATH input 
DIRPATH=${DIRPATH:-$PWD\/downloads}
echo "dirpath ---> ${DIRPATH}"

if [ -d $DIRPATH ]; then
     echo "Image download directory is exist, removing png files under $DIRPATH"
     rm -rf ${DIRPATH}/*.png
	 _current_label="done"
else
     echo "$DIRPATH Not exist!!!, creating it..."
     mkdir ${DIRPATH}
     _current_label="done"	 
fi
}
while [ "$_current_label" != "done" ];
do
  getDIRPATH_function ; 
done

echo "Please enter your username (if not just press Enter): "  
read USERNAME  #Assign input value into a variable 
echo "Please enter your password (if not just press Enter): "  
read PASSWORD  # Assign input value into a variable 

if [-z $USERNAME]; then
     wget -k -O webpage.html --content-disposition $URL # Download index page with wget, "k" option converts local links to global.
else
     wget -k -O webpage.html --content-disposition --user=$USERNAME --password=$PASSWORD $URL # Download index page with wget, "k" option converts local links to global.
fi

# filter throw grep img to get only rows with <img> HTML tag. Second grep get the files having .png extensions case-insensitively. Third grep uses regexp to get links' addresses. sed cuts arguments in links after ? character. Finally, save our links to links.txt

cat webpage.html | grep .png | sed -E -n '/<img/s/.*src="([^"]*)".*/\1/p' > $DIRPATH/links.txt
cat ${DIRPATH}/links.txt | sed -e 's/\.png.*$/.png/' > $DIRPATH/links2.txt
cat | awk '!seen[$0]++' ${DIRPATH}/links2.txt > ${DIRPATH}/links.txt

cd ${DIRPATH} && rm -f links2.txt && wget -i $DIRPATH/links.txt --append-output=logfile  # download all images with this command

# Or You can download and process the links with a single set of pipes, using curl instead as follows:
# curl $URL -L | grep <img> | grep -o src="\"http.*" | grep -o "http.*\"" | sed 's/\?.*//' > links.txt 

# another option:
# curl -s $URL/a.html | sed -En '/<img/s/.*src="([^"]*)".*/\1/p' # Download a web page and getting images