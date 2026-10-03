package br.com.automarketplace.config;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class SpaController {

    @GetMapping({"/", "/login", "/lojista", "/locadora", "/admin", "/alugar"})
    public String index() {
        return "forward:/index.html";
    }
}
