from PIL import Image

im = Image.open('name.bmp', 'r')
pix_val = list(im.getdata())
for i in range(len(pix_val)):
	if pix_val[i] == 0:
		print(0,end='')
	else:
		print(1,end='')
	if i % 436 == 435:
		print('')