b = open("phrases.txt", 'r')
c = open("palavras.txt", 'r')
palavras=c.read()
ola={}
tmp=['f','g','h']

while(len(tmp)>2):
    tmp = b.readline().split(" ")
    for i in tmp:
        if i not in ola:
            if i not in palavras:
                print(i)
                print(i in palavras)
            continue
        ola.append(i,'0')
b.close()
