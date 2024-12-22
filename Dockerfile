ARG VERSION=ltsc2022
FROM mcr.microsoft.com/windows/servercore:$VERSION

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'Continue'; $verbosePreference='Continue';"]
RUN [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; \
    $uri = $(Invoke-RestMethod -UseBasicParsing https://api.github.com/repos/msys2/msys2-installer/releases/latest | \
        Select -ExpandProperty "assets" | \
        Select -ExpandProperty "browser_download_url" | \
        Select-String -Pattern '.sfx.exe$').ToString(); \
    Invoke-WebRequest -UseBasicParsing -Uri $uri -OutFile C:\\windows\\temp\\msys2-base.exe; \
    C:\\windows\\temp\\msys2-base.exe; \
    Remove-Item -Path "C:\\windows\\temp\\msys2-base.exe"; \
    setx /M path "%PATH%;C:\\msys64\\usr\\local\\bin;C:\\msys64\\usr\\bin;C:\\msys64\\bin;C:\\msys64\\usr\\bin\\site_perl;C:\\msys64\\usr\\bin\\vendor_perl;C:\\msys64\\usr\\bin\\core_perl"

SHELL ["bash", "-l", "-c"]
RUN pacman -Syuu --needed --noconfirm --noprogressbar && \
    pacman -Syu --needed --noconfirm --noprogressbar && \
    rm -fr /C/Users/ContainerUser/* /var/cache/pacman/pkg/*

SHELL ["cmd", "/S", "/C"]
RUN mklink /J C:\\msys64\\home\\ContainerUser C:\\Users\\ContainerUser && \
    setx HOME "C:\\msys64\\home\\ContainerUser"

WORKDIR C:\\msys64\\home\\ContainerUser
CMD ["bash", "-l"]
