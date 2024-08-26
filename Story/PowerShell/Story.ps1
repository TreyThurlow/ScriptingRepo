$input = Read-Host "Who are you?"
switch -Wildcard ($input)
    {
        ("*")
            {Write-Host " " 
             Write-Host "Oh, $input, the new detective. I was told about you. My name is Matthew. There was a murder."
             Write-Host " "
             $ans = Read-Host  "Are you able and ready to take the call?"
             switch ($ans)
             {
                ("yes")
                    {Write-Host "The murder was at Hampton Park. I will drive you there now."
                     Write-Host " "
                     Write-Host "As always, Hampton Park puts you in awe with the wonderfully green grass, the tall sprawling live oak trees casting a nice shade to keep away some of the heat, the water going through the park, but mainly, the quiet. You started walking towards were everyone was crowded by police tape and an officer stops you and Matthew."
					 Write-Output " "
					 $tone = Read-Host "`"Hey! You two! Stop! Where do you think you are going?`" (type either rude or polite)" 
					 switch ($tone)
						{
							("rude")
								{Write-Host "Rude Text"}
							("polite")
								{Write-Host "Polite Text"}
						}
					}
				{("no") -or ("why")}
					{Write-Host "Try Again"}
					}
			}
	}

                
