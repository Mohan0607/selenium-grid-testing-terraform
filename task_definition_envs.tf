locals {

  node_environments = [
    {
      "name" : "SE_EVENT_BUS_HOST",
      "value" : "hub.selenium"
    },
    {
      "name" : "HUB_PORT",
      "value" : tostring(local.selenium_hub_container_port)
    },
    {
      "name" : "SE_EVENT_BUS_PUBLISH_PORT",
      "value" : "4442"
    },
    {
      "name" : "SE_EVENT_BUS_SUBSCRIBE_PORT",
      "value" : "4443"
    },
    {
      "name" : "NODE_MAX_SESSION",
      "value" : "3"
    },
    {
      "name" : "NODE_MAX_INSTANCES",
      "value" : "3"
    }
  ]

}


