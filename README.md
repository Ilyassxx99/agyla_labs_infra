# Project Setup & Cloning Guide

Welcome! This README will provide you with instructions on how to create a new folder, clone another GitHub repository into it, create a new private GitHub repository, push the folder into the new private repository, and run Terraform infrastructure.

## Catpipeline Project

### Create a new folder and clone a GitHub repo into it

1. Open your terminal/command prompt.

3. Create a new folder using the `mkdir` command:
```
mkdir agyla-labs
```

4. Navigate to the new folder:
```
cd agyla-labs
```

5. Clone the GitHub repository containing the app source code into the new folder using the `git clone` command:
```
git clone https://github.com/Ilyassxx99/catpipeline.git
```

### Create a new private GitHub repository

1. Log in to your GitHub account.

2. Click on the "+" icon in the upper-right corner and select "New repository".

3. Enter a repository name, and select the "Private" visibility option.

4. Uncheck the add a README.me option.

5. Click "Create repository".

### Push the previous folder into the new private repository

1. In your terminal/command prompt, navigate to the folder you created earlier.
```
cd agyla-labs/catpipeline
```

2. Add the new private GitHub repository as a remote using the `git remote add` command:
```
git remote set-url origin https://github.com/your-username/new-private-repo.git
```
Replace `your-username` with your GitHub username and `new-private-repo` with the private repository name.

3. Add all files and folders in the directory to the Git repository using the `git add` command:
```
git add .
```

4. Commit your changes using the `git commit` command:
```
git commit -m "Initial commit"
```

5. Push the changes to the new private repository using the `git push` command:
```
git push -u origin main
```

### Run Terraform infrastructure

1. Install Terraform on your machine by following the official installation guide: [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

2. In your terminal/command prompt, navigate to the directory containing the Catpipeline Terraform configuration files (`.tf` files).
```
git clone https://github.com/Ilyassxx99/agyla_labs_infra.git
cd agyla_labs_infra/catpipeline/environments/development
```

3. Initialize the Terraform working directory by running the following command:
```
terraform init
```

4. Verify the Terraform configuration by running the following command:
```
terraform validate
```

5. Review the execution plan by running the following command:
```
terraform plan
```

6. Apply the Terraform configuration by running the following command:
```
terraform apply
```

You will be prompted to confirm that you want to proceed. Type `yes` and press Enter to continue.

7. After the infrastructure has been successfully created, you can inspect the state by running the following command:
```
terraform show
```
