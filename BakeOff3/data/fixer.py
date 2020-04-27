a = open("count_1w.txt", 'r')
b = open("palavras.txt", 'w')
tmp=[0,0,0]

while(len(tmp)>1):
    tmp = a.readline().split("\t")
    b.write(tmp[0]+'\n')
a.close()
b.close()
