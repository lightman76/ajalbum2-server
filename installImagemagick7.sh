apt-get update
apt-get -y install wget gcc make libpng12-dev
curl -L https://imagemagick.org/download/ImageMagick.tar.gz > ImageMagick.tar.gz
tar xvzf ImageMagick.tar.gz
rm ImageMagick.tar.gz
cd ImageMagick-7*
./configure
make
echo "  ImageMagick Make!"
make install
echo "  ImageMagick Make install completed!"
ldconfig /usr/local/lib
echo "  ImageMagick ldconfig completed!"
#Clean up
rm -rf ImageMagick-7*
#make check
