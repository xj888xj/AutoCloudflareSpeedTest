import csv
import requests
from concurrent.futures import ThreadPoolExecutor

def get_location(ip):
    try:
        response = requests.get(f'http://ip-api.com/json/{ip}')
        data = response.json()
        if data['status'] == 'success':
            return data['countryCode']
    except requests.RequestException:
        return None

def convert_csv_to_tls(csv_filename, output_filename, notls=False):
    with open(csv_filename, 'r', encoding='utf-8') as infile, open(output_filename, 'w', encoding='utf-8') as outfile:
        reader = csv.reader(infile)
        next(reader)  # Skip header row
        for row in reader:
            ip = row[0]
            countryCode = get_location(ip)
            if countryCode:
                variable = f"[{countryCode}]"
            else:
                variable = "[位置获取失败]"

            if notls:
                formatted_ip = f"{ip}"
            else:
                formatted_ip = f"{ip}"

            outfile.write(formatted_ip + '\n')

def main():
    csv_filenames = ['SG-443.csv', 'US-443.csv', 'KR-443.csv', 'JP-443.csv', 'HK-443.csv']
    output_filenames = ['SG-443.txt', 'US-443.txt', 'KR-443.txt', 'JP-443.txt', 'HK-443.txt']

    with ThreadPoolExecutor() as executor:
        executor.map(convert_csv_to_tls, csv_filenames, output_filenames)

if __name__ == "__main__":
    main()
