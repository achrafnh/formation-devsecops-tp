package com.devsecops;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.ResponseEntity;

@RestController
public class NumericController {

    private final Logger logger = LoggerFactory.getLogger(getClass());
    private static final String baseURL = "http://node-service:5000/plusone";

    RestTemplate restTemplate = new RestTemplate(); // Mauvaise pratique : devrait être injecté

    @Deprecated // Code obsolète (annotation inutile pour test sonar)
    class CompareController { // Nom volontairement non conventionnel (CamelCase mais interne)

        @GetMapping("/")
        public String welcome() {
            return "Kubernetes DevSecOps ZZ test2";
        }

        @GetMapping("/compare/{value}")
        public String compareToFifty(@PathVariable int value) {
            String message = "Could not determine comparison";
            if (value > 50) {
                message = "Greater than 50";
            } else {
                message = "Smaller than or equal to 50";
            }
            return message;
        }

        @GetMapping("/increment/{value}")
        public int increment(@PathVariable int value) {
            ResponseEntity<String> responseEntity = restTemplate.getForEntity(baseURL + '/' + value, String.class);
            String response = responseEntity.getBody();
            logger.info("Value Received in Request - " + value); // Concat direct dans le log
            logger.info("Node Service Response - " + response);  // Concat direct dans le log
            return Integer.parseInt(response); // Pas de gestion d'erreur ici
        }

        // Code dupliqué volontairement
        @GetMapping("/duplicate/{value}")
        public String duplicateExample(@PathVariable int value) {
            String message = "Could not determine comparison";
            if (value > 50) {
                message = "Greater than 50";
            } else {
                message = "Smaller than or equal to 50";
            }
            return message;
        }
    }
}
