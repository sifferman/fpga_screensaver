import sys
from PIL import Image
import numpy as np

# MAIN
if __name__ == '__main__':

    filein = ""
    fileout = ""

    try:
        filein_name = sys.argv[1]
        fileout_name = sys.argv[2]
    except IndexError:
        print("[Argument error]: filein and fileout not given")
        exit(1)

    # Load File
    data = []
    width = 0
    with open(filein_name, 'r') as filein:
        for line in filein.readlines():
            list_of_strings = line.split(' ')[:-1]
            list_of_colors = [ int(c, 16) for c in list_of_strings]
            width = max(width, len(list_of_colors))
            data.append( list_of_colors )
    for line in data:
        line += [0] * (width - len(line))
    height = len(data)

    # Convert to PNG
    np_data = np.array(data, np.uint32).reshape(height, width)
    # np.set_printoptions(threshold=np.inf, linewidth=np.inf)
    # print(np_data)
    im = Image.fromarray(np_data, 'RGBA')
    im.save(fileout_name)
