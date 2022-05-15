
import datetime
import requests

sum = int(input("Количество параграфов: "))
while 5 > sum:
    sum = int(input('Введенное кол-во параграфов меньше 5, введите минимум 5 параграфов: '))

doc = requests.get(f"https://baconipsum.com/api/?type=meat-and-filler&paras={sum}")
doc_list = doc.json()
doc_log = datetime.date.today()
print(f'runnig {doc_log}')

doc_list.reverse()
print(doc_list)
name = 'Vadim Beznosenko'
pl = 0
new_list = []
for i in doc_list:
    if 'Pancetta' in i or 'pancetta' in i:
        pl += 1
    elif 'Pancetta,' in i or 'pancetta,' in i:
        pl += 1
    elif "'Pancetta" in i or 'pancetta.' in i:
        pl += 1
    else:
        continue
for i in doc_list:
    new_list.append(f'{i}\n')
print(f"Найдено {pl} слов 'Pancetta'")
out = [name, doc_log, pl, new_list]
with open('HW_08.txt', 'w') as file_doc:
    for i in out:
        file_doc.write(f"{i}\n")

