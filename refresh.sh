if [[ -d AppSTARTer/ ]]; then
    if [[ -d AppSTARTer/.apps/ ]]; then
        rm -r .appstarter/.apps/
        cp -r AppSTARTer/.apps/ .appstarter/
    else
       echo "AppSTARTer/.apps/ directory not found"
    fi

    if [[ -d AppSTARTer/.scripts/ ]]; then
        rm -r .appstarter/.scripts/
        cp -r AppSTARTer/.scripts/ .appstarter/
    else
       echo "AppSTARTer/.scripts/ directory not found"
    fi

    cp AppSTARTer/main.sh .appstarter/
else
    echo "AppSTARTer/ does not exist"
fi