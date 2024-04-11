job "remove-limits-stage-sepolia" {
    datacenters = ["ator-fin"]
    type = "batch"

    reschedule {
        attempts = 0
    }

    task "remove-limits-stage-task" {
        driver = "docker"

        config {
            network_mode = "host"
            image = "ghcr.io/ator-development/ator-token:1.1.16"
            entrypoint = ["npx"]
            command = "hardhat"
            args = ["run", "--network", "sepolia", "scripts/remove-limits.ts"]
        }

        vault {
            policies = ["ator-token-sepolia-stage"]
        }

        template {
            data = <<EOH
            {{with secret "kv/ator-token/sepolia/stage"}}
                TOKEN_DEPLOYER_KEY="{{.Data.data.TOKEN_DEPLOYER_KEY}}"
                CONSUL_TOKEN="{{.Data.data.CONSUL_TOKEN}}"
                JSON_RPC="{{.Data.data.JSON_RPC}}"
            {{end}}
            EOH
            destination = "secrets/file.env"
            env         = true
        }

        env {
            PHASE="stage"
            CONSUL_IP="127.0.0.1"
            CONSUL_PORT="8500"
            CONSUL_KEY="ator-token/sepolia/stage/address"
        }

        restart {
            attempts = 0
            mode = "fail"
        }

        resources {
            cpu    = 4096
            memory = 4096
        }
    }
}
