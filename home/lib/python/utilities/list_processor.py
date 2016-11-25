import os, re, sys

class ListProcessor(object):
    def __init__(self, list_name):
        assert list_name
        self.__list_name = list_name

    @property
    def __database(self):
        if not hasattr(self, '__database__'):
            self.__database__ = self.__get_database()
        return self.__database__

    @property
    def __database_file_path(self):
        if not hasattr(self, '__database_file_path__'):
            self.__database_file_path__ = self.__get_database_file_path()
        return self.__database_file_path__

    @property
    def __valid_buckets(self):
        if not hasattr(self, '__valid_buckets__'):
            self.__valid_buckets__ = self.__get_valid_buckets()
        return self.__valid_buckets__

    def process(self, *args):
        self.__ensure_database_exists()
        if not args:
            return self.__render()
        if not re.match(r'^[1-9][0-9]*(:[1-9][0-9]*)*$', args[0]):
            return self.__add(' '.join(args))
        index = int(args[0]) - 1
        if not args[1:]:
            return self.__render(index)
        operation = args[1]
        if operation in ['d', 'done']:
            return self.__done(index)
        elif operation in ['e', 'edit']:
            return self.__edit(index, ' '.join(args[2:]))
        elif operation in ['r', 'remove']:
            return self.__remove(index)
        else:
            return False

    def __add(self, line):
        if not line:
            return False
        self.__database.setdefault('a', []).append(line)
        return self.__write_database()

    def __done(self, index):
        if index < 0:
            return False
        self.__database.setdefault('d', []).append(self.__database['a'].pop(index))
        return self.__write_database()

    def __edit(self, index, line):
        if not line or index < 0:
            return False
        self.__database['a'][index] = line
        return self.__write_database()

    def __ensure_database_exists(self):
        database_file_path = self.__database_file_path
        database_dirname = os.path.dirname(database_file_path)
        if database_dirname and not os.path.isdir(database_dirname):
            os.makedirs(database_dirname)
        if not os.path.isfile(database_file_path):
            open(self.__database_file_path, 'w').close()

    def __get_bucket(self, bucket):
        return self.__database.get(bucket, None)

    def __get_database(self):
        return self.__read_database()

    def __get_database_file_path(self):
        list_name = self.__list_name
        env_var = '%s_DATABASE' % list_name
        if os.getenv(env_var):
            return os.getenv(env_var)
        if os.path.isfile(list_name):
            return list_name
        return os.path.join(
            os.getenv('HOME'),
            'var',
            'db',
            list_name
        )

    def __get_valid_buckets(self):
        return [
            'a',
            'd',
            'r',
        ]

    def __read_database(self):
        database = {}
        with open(self.__database_file_path) as database_file:
            for line in database_file:
                line_parts = line.rstrip("\r\n").split(' ')
                if not line_parts:
                    continue
                bucket = line_parts[0]
                if bucket not in self.__valid_buckets:
                    continue
                message_parts = line_parts[1:]
                if not message_parts:
                    continue
                database.setdefault(bucket, []).append(' '.join(message_parts))
        return database

    def __remove(self, index):
        if index < 0:
            return False
        self.__database.setdefault('r', []).append(self.__database['a'].pop(index))
        return self.__write_database()

    def __render(self, index=None):
        lines = self.__get_bucket('a')
        if not lines:
            print 'No results'
            return True
        for line_index, line in enumerate(lines):
            if not index or line_index == index:
                print '%3d. %s' % (line_index + 1, line)
        return True

    def __write_database(self):
        with open(self.__database_file_path, 'w') as database_file:
            for bucket, lines in self.__database.iteritems():
                for line in lines:
                    database_file.write("%s %s%s" % (
                        bucket,
                        line,
                        os.linesep
                    ))
        return True


if __name__ == '__main__':
    list_name = os.getenv('LIST_NAME')
    processor = ListProcessor(list_name)
    result = processor.process(*sys.argv[1:])
    sys.exit(0 if result else 1)
