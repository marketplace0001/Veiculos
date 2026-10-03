package br.com.automarketplace;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import static org.hamcrest.Matchers.greaterThan;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class AutoMarketplaceSmokeTest {

    @Autowired MockMvc mvc;
    @Autowired ObjectMapper mapper;

    @Test
    void publicCatalogLoads() throws Exception {
        mvc.perform(get("/api/public/vehicles"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()", greaterThan(0)));

        mvc.perform(get("/api/public/rentals"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()", greaterThan(0)));
    }

    @Test
    void dealerLoginAndProtectedEndpointWork() throws Exception {
        String token = login("lojista@automarketplace.local", "Loja@123");
        mvc.perform(get("/api/dealer/vehicles").header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()", greaterThan(0)));
    }

    @Test
    void rentalLoginAndProtectedEndpointWork() throws Exception {
        String token = login("locadora@automarketplace.local", "Locadora@123");
        mvc.perform(get("/api/rental/vehicles").header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()", greaterThan(0)));
    }

    @Test
    void adminLoginAndStatsWork() throws Exception {
        String token = login("admin@automarketplace.local", "Admin@123");
        mvc.perform(get("/api/admin/stats").header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.stores").value(3));
    }

    @Test
    void publicLeadCanBeCreated() throws Exception {
        String body = """
                {"name":"Teste","phone":"5599999999999","type":"INTEREST","vehicleId":1}
                """;
        mvc.perform(post("/api/leads").contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").exists());
    }

    private String login(String email, String password) throws Exception {
        String body = mapper.writeValueAsString(new LoginPayload(email, password));
        MvcResult result = mvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token").isNotEmpty())
                .andReturn();
        JsonNode json = mapper.readTree(result.getResponse().getContentAsString());
        return json.get("token").asText();
    }

    record LoginPayload(String email, String password) {}
}
