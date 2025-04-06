using System;
using System.Data.Common;
using System.Threading;
using Newtonsoft.Json;
using Npgsql;
using StackExchange.Redis;

namespace Worker
{
    public class Program
    {
        public static int Main(string[] args)
        {
            try
            {

                // Get database connection string from environment variables
                var dbHost = Environment.GetEnvironmentVariable("DB_HOST") ?? "localhost";
                var dbUser = Environment.GetEnvironmentVariable("DB_USER") ?? "postgres";
                var dbPassword = Environment.GetEnvironmentVariable("DB_PASSWORD") ?? "postgres";
                var dbConnectionString = $"Server={dbHost};Username={dbUser};Password={dbPassword};SSL Mode=Require;Trust Server Certificate=true;";

                var pgsql = OpenDbConnection(dbConnectionString);


                var redisConn = OpenRedisConnection();
                var redis = redisConn.GetDatabase();

                var keepAliveCommand = pgsql.CreateCommand();
                keepAliveCommand.CommandText = "SELECT 1";

                var definition = new { vote = "", voter_id = "" };
                while (true)
                {
                    Thread.Sleep(100);

                    // Reconnect Redis if needed
                    if (!redisConn.IsConnected)
                    {
                        Console.WriteLine("Reconnecting Redis");
                        redisConn = OpenRedisConnection();
                        redis = redisConn.GetDatabase();
                    }

                    string json = redis.ListLeftPopAsync("votes").Result;
                    if (json != null)
                    {
                        var vote = JsonConvert.DeserializeAnonymousType(json, definition);
                        Console.WriteLine($"Processing vote for '{vote.vote}' by '{vote.voter_id}'");
                        
                        // Reconnect PostgreSQL if needed
                        if (!pgsql.State.Equals(System.Data.ConnectionState.Open))
                        {
                            Console.WriteLine("Reconnecting DB");
                            pgsql = OpenDbConnection(dbConnectionString);

                        }
                        
                        UpdateVote(pgsql, vote.voter_id, vote.vote); // This call must match the method definition
                    }
                    else
                    {
                        keepAliveCommand.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine(ex.ToString());
                return 1;
            }
        }

        private static NpgsqlConnection OpenDbConnection(string connectionString)
        {
            while (true)
            {
                try
                {
                    var conn = new NpgsqlConnection(connectionString);
                    conn.Open();
                    Console.Error.WriteLine("Connected to PostgreSQL");

                    using var cmd = conn.CreateCommand();
                    cmd.CommandText = @"CREATE TABLE IF NOT EXISTS votes (
                                        id VARCHAR(255) NOT NULL UNIQUE,
                                        vote VARCHAR(255) NOT NULL
                                    )";
                    cmd.ExecuteNonQuery();
                    return conn;
                }
                catch (Exception)
                {
                    Console.Error.WriteLine("Waiting for PostgreSQL");
                    Thread.Sleep(1000);
                }
            }
        }

        private static ConnectionMultiplexer OpenRedisConnection()
        {

            // Get Redis connection details from environment variables
            var redisHost = Environment.GetEnvironmentVariable("REDIS_HOST") ?? "localhost";
            var redisPort = Environment.GetEnvironmentVariable("REDIS_PORT") ?? "6379";


            var options = new ConfigurationOptions
            {
                EndPoints = { $"{redisHost}:{redisPort}" },
                // Ssl = true,
                AbortOnConnectFail = false
            };

            while (true)
            {
                try
                {
                    Console.Error.WriteLine("Connecting to Redis");
                    return ConnectionMultiplexer.Connect(options);
                }
                catch (RedisConnectionException)
                {
                    Console.Error.WriteLine("Waiting for Redis");
                    Thread.Sleep(1000);
                }
            }
        }

        // ▼ THIS METHOD WAS MISSING OR MISPLACED ▼
        private static void UpdateVote(NpgsqlConnection connection, string voterId, string vote)
        {
            using var command = connection.CreateCommand();
            try
            {
                command.CommandText = "INSERT INTO votes (id, vote) VALUES (@id, @vote)";
                command.Parameters.AddWithValue("@id", voterId);
                command.Parameters.AddWithValue("@vote", vote);
                command.ExecuteNonQuery();
            }
            catch (DbException)
            {
                command.CommandText = "UPDATE votes SET vote = @vote WHERE id = @id";
                command.ExecuteNonQuery();
            }
        }
    }
}
