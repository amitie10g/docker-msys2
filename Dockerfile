ARG VERSION=ltsc2022
FROM mcr.microsoft.com/windows/servercore:$VERSION

RUN powershell -Command "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; \
    $uri = $(Invoke-RestMethod -UseBasicParsing https://api.github.com/repos/msys2/msys2-installer/releases/latest | \
            Select -ExpandProperty 'assets' | \
            Select -ExpandProperty 'browser_download_url' | \
            Select-String -Pattern '.sfx.exe$').ToString(); \
    Invoke-WebRequest -UseBasicParsing -Uri $uri -OutFile C:\\windows\\temp\\msys2-base.exe" && \
	C:\\windows\\temp\\msys2-base.exe && \
	del "C:\windows\temp\msys2-base.exe" && \
    setx /M path "%PATH%;C:\msys64\usr\local\bin;C:\msys64\usr\bin;C:\msys64\bin;C:\msys64\usr\bin\site_perl;C:\msys64\usr\bin\vendor_perl;C:\msys64\usr\bin\core_perl" && \
	setx HOME "C:\msys64\home\ContainerUser" && \
	mklink /J C:\\msys64\\home\\ContainerUser C:\\Users\\ContainerUser

RUN	bash -l -c "pacman -Syuu --needed --noconfirm --noprogressbar" && \
	bash -l -c "pacman -Syu --needed --noconfirm --noprogressbar" && \
	bash -l -c "rm -fr /C/Users/ContainerUser/* /var/cache/pacman/pkg/*"
	
WORKDIR C:\\msys64\\home\\ContainerUser\\
CMD ["bash", "-l"]
