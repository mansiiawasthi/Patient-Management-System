import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class BCryptTest {

    public static void main(String[] args) {

        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

        String password = "Password123";

        String hash = "$2a$10$t0mQTqAaT0DX3jo5Q4v8quFARcgAfE62z/ebogtGNlwwUYqO7Am5O";

        boolean result = encoder.matches(password, hash);

        System.out.println("Password matches: " + result);
    }
}