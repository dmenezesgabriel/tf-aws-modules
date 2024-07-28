from src.adapter.aws import AWSClientAdapter


class SSMParameterStoreAdapter(AWSClientAdapter):
    def __init__(self, client_type="ssm"):
        super().__init__(client_type=client_type)

    def get_parameter(self, name: str) -> str:
        response = self.client.get_parameter(Name=name, WithDecryption=True)
        return response["Parameter"]["Value"]
