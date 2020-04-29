a = open("count_2w.txt", 'r')
b = open("palavras2.txt", 'w')
tmp=[0,0,0]

while(len(tmp)>1):
    tmp = a.readline().split("\t")
    tmp=tmp[0].split(" ")
    if(ord(tmp[0][0])<ord('A') or ord(tmp[1][0])<ord('A')):
        continue
    b.write((tmp[0]+' '+tmp[1]+'\n').lower())
a.close()
b.close()
