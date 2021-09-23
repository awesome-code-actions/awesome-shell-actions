function ssl-test-pub-private-key() {
	# @arg-len:2
	# @tag ssl demo
	local pub=$1
	local private=$2

    echo "hello,world!" > test_rsa.txt
	echo "\n======test_rsa.txt======\n"
	cat ./test_rsa.txt
	echo "\n======test_rsa.txt======\n"

	# 使用公钥加密文件
    openssl rsautl -encrypt -inkey $pub -pubin -in test_rsa.txt -out test_rsa.enc -out test_rsa.enc
	echo "\n======test_rsa.enc======\n"
	base64 ./test_rsa.enc
	echo "\n======test_rsa.enc======\n"

	# 使用私钥加密文件
	openssl rsautl -decrypt -inkey $private -in test_rsa.enc -out test_rsa.decrtpt
	echo "\n======test_rsa.decrtpt======\n"
	cat ./test_rsa.decrtpt
	echo "\n======test_rsa.decrtpt======\n"

	# 使用私钥签名文件
    openssl dgst -sha256 -sign $private -out ./test_rsa.txt.sign.sha256 ./test_rsa.txt
	echo "\n======./test_rsa.txt.sign.sha256======\n"
	base64 ./test_rsa.txt.sign.sha256
	echo "\n======./test_rsa.txt.sign.sha256======\n"

	# 使用公钥验证签名文件
	openssl dgst -sha256 -verify $pub -signature ./test_rsa.txt.sign.sha256 ./test_rsa.txt

}