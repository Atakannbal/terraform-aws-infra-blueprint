import com.sun.net.httpserver.HttpServer;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Statement;

public class server {

    private static final String DB_URL = System.getenv("DB_URL");
    private static final String DB_USER = System.getenv("DB_USER");
    private static final String DB_PASSWORD = System.getenv("DB_PASSWORD");
    private static Connection dbConnection;


    public static void main(String[] args) throws IOException {

        // Initializa single connection
        try {
            dbConnection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            dbConnection.setAutoCommit(true); // Ensure commits happen per request
            createTableIfNotExists();
        } catch (SQLException e) {
            e.printStackTrace();
            return;
        }

        HttpServer server = HttpServer.create(new InetSocketAddress(8080), 0);
        server.createContext("/sum", exchange -> {
            exchange.getResponseHeaders().set("Access-Control-Allow-Origin", "*");
            
            String query = exchange.getRequestURI().getQuery(); // "1+2"
            String[] params = query.split("\\+"); // Split by "+"
            int num1 = Integer.parseInt(params[0]);
            int num2 = Integer.parseInt(params[1]);
            int sum = num1 + num2;
            
            try {
              storeResult(num1, num2, sum);
            } catch (Exception e) {
                e.printStackTrace();
                exchange.sendResponseHeaders(500, 0);
                exchange.getResponseBody().close();
                return;
            }

            String response = String.valueOf(sum);

            exchange.sendResponseHeaders(200, response.length());
            exchange.getResponseBody().write(response.getBytes());
            exchange.getResponseBody().close();
        });

        server.start();
        System.out.println("Server started on port 8080");
    }

    private static void createTableIfNotExists() {
        String sql =
            "CREATE TABLE IF NOT EXISTS sums (" +
            "id SERIAL PRIMARY KEY, " +
            "num1 INT NOT NULL, " +
            "num2 INT NOT NULL, " +
            "result INT NOT NULL)";
        try (
            Connection conn = DriverManager.getConnection(
                DB_URL,
                DB_USER,
                DB_PASSWORD
            );
            Statement stmt = conn.createStatement()
        ) {
            stmt.execute(sql);
            System.out.println("Table 'sums' is ready.");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private static int storeResult(int num1, int num2, int result) throws SQLException  {
        String sql = "INSERT INTO sums (num1, num2, result) VALUES (?, ?, ?)";
        try (PreparedStatement stmt = dbConnection.prepareStatement(sql)) {
            stmt.setInt(1, num1);
            stmt.setInt(2, num2);
            stmt.setInt(3, result);
            stmt.executeUpdate();
            System.out.println("Stored result: " + result);
            return result;
        }
    }
}
