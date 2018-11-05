https://www.spinics.net/lists/linux-mm/msg147669.html
https://lkml.kernel.org/r/CA+55aFy6h1c3_rP_bXFedsTXzwW+9Q9MfJaW7GUmMBrAp-fJ9A@mail.gmail.com
https://lore.kernel.org/lkml/CA+55aFzCG-zNmZwX4A2FQpadafLfEzK6CC=qPXydAacU1RqZWA@mail.gmail.com/T/#u
https://lore.kernel.org/lkml/20180327203904.GA1151@beast/T/#u



## Infer Capture and Analyze

| Results  | Linux-4.18 maximalyesconfig | Linux-4.18 defconfig | Linux-4.19 maximalyesconfig | Linux-4.19 defconfig |
| ------------- | ------------- | ------------- | ------------- |  ------------- |
| Infer 0.15.0  | ERR[1]  | OK[2] | ERR[3] | ERR[4] |

| Results  | Linux-4.17 defconfig | Linux-4.16 defconfig |
| ------------- | ------------- | ------------- |
| Infer 0.15.0  | OK[5]  | OK[6] |

| Results | Linux-4.18 maximalnoconfig | Linux-4.18 allnoconfig | Linux-4.18 randconfig |
|---------|----------------------------|------------------------|-----------------------|
| Infer 0.15.0 | | |


