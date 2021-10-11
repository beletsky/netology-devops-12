#!/usr/bin/env python3

import csv
import os

services = [
    'drive.google.com',
    'mail.google.com',
    'google.com',
]

ip_cache_filename = 'services_ip.csv'

class IpCache:
    def __init__(self, services, filename):
        self.__services = services
        self.__filename = filename
        self.__ip_cache = {}
        self.read()

    def read(self):
        if not os.path.isfile(self.__filename):
            return
        with open(self.__filename) as f:
            reader = csv.reader(f)
            for row in reader:
                if row[0] not in self.__services:
                    continue
                self.__ip_cache[row[0]] = row[1]

    def write(self):
        with open(self.__filename, 'w') as f:
            writer = csv.writer(f)
            for service, ip in self.__ip_cache.items():
                writer.writerow([service, ip])

    def __contains__(self, service):
        return service in self.__ip_cache

    def get(self, service, default = None):
        return self.__ip_cache.get(service, default)

    def __getitem__(self, service):
        # If service isn't in the list, assume that ip is matched.
        return self.__ip_cache[service]

    def __setitem__(self, service, ip):
        # Do not store ip for unknown service.
        if service not in self.__services:
            return

        self.__ip_cache[service] = ip


def test_ip_cache():
    test_filename = 'test_' + ip_cache_filename

    ip_cache = IpCache(['google.com', 'fake.google.com'], test_filename)
    ip_cache['google.com'] = '1.1.1.1'
    ip_cache['fake.google.com'] = '2.2.2.2'
    ip_cache['fake2.google.com'] = '3.3.3.3'

    # Check services for presence in cache.
    if 'google.com' not in ip_cache:
        raise Exception('Service is missing from cache')
    if 'fake.google.com' not in ip_cache:
        raise Exception('Service is missing from cache')
    if 'fake2.google.com' in ip_cache:
        raise Exception('Wrong service appeared in cache')

    # Check services for right ips.
    if ip_cache['google.com'] != '1.1.1.1':
        raise Exception('IP mismatches')
    if ip_cache['fake.google.com'] != '2.2.2.2':
        raise Exception('IP mismatches')

    ip_cache.write()

    try:
        # Reread the cache.
        del ip_cache

        ip_cache = IpCache(['google.com'], test_filename)

        # Check services for presence in cache.
        if 'google.com' not in ip_cache:
            raise Exception('Service is missing from cache')
        if 'fake.google.com' in ip_cache:
            raise Exception('Service is missing from cache')

        # Check services for right ips.
        if ip_cache['google.com'] != '1.1.1.1':
            raise Exception('IP mismatches')

    finally:
        os.remove(test_filename)


if __name__ == '__main__':
    # Uncomment the following line to testing.
    # test_ip_cache(); exit()

    ip_cache = IpCache(services, ip_cache_filename)
    for service in services:
        # Get the service ip.
        ip = '1.1.1.1'

        # Check ip for matching.
        if service in ip_cache:
            if (old_ip := ip_cache[service]) != ip:
                print(f'[ERROR] {service} IP mismatch: {old_ip} {ip}')

        ip_cache[service] = ip
        print(f'{service} - {ip}')

    ip_cache.write()
