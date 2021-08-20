class Dog

    attr_accessor :name, :breed, :id



    def initialize(name:, breed:, id:nil)
        @id = id
        @name = name
        @breed = breed
    end


    def save

        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)

        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

        return self
    end


    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            breed TEXT,
            name TEXT
        )
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL

        DROP TABLE dogs;

        SQL

        DB[:conn].execute(sql)
    end


    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.all
        sql = <<-SQL
            SELECT *
            FROM dogs
        SQL

        DB[:conn].execute(sql).map do |row|
            self.new_from_db(row)
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
        SQL

        self.new_from_db(DB[:conn].execute(sql, name)[0])
        
    end


    def self.find(id)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE id = ?
        SQL

        self.new_from_db(DB[:conn].execute(sql, id)[0])

    end

end
