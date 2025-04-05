 set -e

   OS_ID=$(grep -w ID /etc/os-release | cut -d'=' -f2 | tr -d '"')
    OS_NAME=$(grep -w PRETTY_NAME /etc/os-release | cut -d'=' -f2 | tr -d '"')
    OS_VERSION=$(grep -w VERSION_ID /etc/os-release | cut -d'=' -f2 | tr -d '"')

    if [[ "$OS_ID" == "ubuntu" ]]; then
        echo "Setting up dependencies for $OS_NAME"
        sudo apt update -y
        sudo apt install --no-install-recommends software-properties-common -y

        case "$OS_VERSION" in
            "20.04")
                sudo add-apt-repository ppa:vbernat/haproxy-2.0 -y
                ;;
            "22.04"|"24.04")
                sudo add-apt-repository ppa:vbernat/haproxy-2.8 -y
                ;;
            *)
                echo "Unsupported Ubuntu version: $OS_VERSION"
                return
                ;;
        esac

        sudo apt update
        sudo apt -y install haproxy

    elif [[ "$OS_ID" == "debian" ]]; then
        echo "Setting up dependencies for $OS_NAME"

        curl -fsSL https://haproxy.debian.net/bernat.debian.org.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/haproxy.debian.net.gpg > /dev/null

        case "$OS_VERSION" in
            "10")
                echo "deb [signed-by=/usr/share/keyrings/haproxy.debian.net.gpg] http://haproxy.debian.net buster-backports-2.2 main" | sudo tee /etc/apt/sources.list.d/haproxy.list
                ;;
            "11")
                echo "deb [signed-by=/usr/share/keyrings/haproxy.debian.net.gpg] http://haproxy.debian.net bullseye-backports-2.4 main" | sudo tee /etc/apt/sources.list.d/haproxy.list
                ;;
            "12")
                echo "deb [signed-by=/usr/share/keyrings/haproxy.debian.net.gpg] http://haproxy.debian.net bookworm-backports-2.8 main" | sudo tee /etc/apt/sources.list.d/haproxy.list
                ;;
            *)
                echo "Unsupported Debian version: $OS_VERSION"
                return
                ;;
        esac

        sudo apt update
        sudo apt -y install haproxy

    else
        echo "Your OS is not supported: $OS_NAME"
        return
    fi