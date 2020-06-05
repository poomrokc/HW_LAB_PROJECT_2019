from PIL import Image

im = Image.open('start.bmp', 'r')
pix_val = list(im.getdata())
for i in range(len(pix_val)):
	if pix_val[i] == 0:
		print('12\'b'+'{0:012b}'.format(i)+': data = 1;')