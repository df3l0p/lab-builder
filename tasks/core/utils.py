import os
import configparser
import io

def check_context(
    context, 
    stanza_name="main",
    required_args=[
        "build_path",
        "vagrantfile",
    ]
):
    """
    Check that the context object contains the mandatory fields.
    :param context: configuration context object
    :type context: dict
    :param stanza_name: name of the stanza
    :param required_args: array of args that the context must have
    """
    # Check for the stanza
    if "main" not in context:
        raise ValueError("main stanza not defined")

    # Check for the field names
    for arg in required_args:
        if arg not in context["main"].keys():
            raise ValueError("{} field name not defined".format(arg))

def context_from_config(path=None):
    """Return context object from context file path.

    :param path: path to context file
        if none provided it will look for SPLUNK_CTX env variable.
    :return: a dict of dict. The key correspond to service
    (hfb, sh, ...) and the values to the parameters
    """
    def decrypt_values(services, secret):
        for service, params in services.items():
            for key, val in params.items():
                if val.startswith('SECRET::'):
                    if not secret:
                        secret = getpass.getpass()
                    params[key] = decrypt_value(secret, val)

    secret = os.getenv('CONTEXT_SECRET')
    res = {}
    # Do not carry on if the path to the context is not correct
    if path is None or not os.path.exists(path):
        return None
    # Retrieve configuration
    with open(path) as base_conf_file:
        config = configparser.ConfigParser(
            interpolation=None,
        )
        config.readfp(base_conf_file)
        for service in config.sections():
            res[service] = dict(config.items(service))
    
    decrypt_values(res, secret)
    check_context(res)
    return res

def substitute(ctx, params):
    """Walk project to do template subsitution"""
    substs = filter_prefix(params, 'subst-')
    # make sure build_path is defined
    if 'build_path' not in params:
        raise ValueError("build_path not defined in context")
    build_path = params['build_path']
    build_path = os.path.join(os.getcwd(), build_path)

    command = ('grep -rl '
                '"{{%s}}" %s')
    
    for key, value in substs.items():
        res = ctx.run(
            command % (
                key, build_path,
            ),
            warn=True,
            echo=True,
        )
        for match_path in res.stdout.split("\n"):
            if not match_path:
                continue
            with io.open(match_path, encoding='utf8') as rfile:
                content = rfile.read()
                content = content.replace("{{%s}}" % key, value)

            with io.open(match_path, encoding='utf8', mode='w') as rfile:
                rfile.write(content)

def encrypt_value(key, value):
    """Encrypt value with key
    :param key: secret key to encode the value
    :param value: Clear value to encrypt
    :return: encrypted values encoded in base 64
    with SECRET:: prefix
    """
    secret = hashlib.sha256(key).hexdigest()[0:32]
    cipher = ChaCha20.new(key=secret)
    msg = cipher.nonce + cipher.encrypt(value)
    res = 'SECRET::{}'.format(base64.b64encode(msg))
    return res

def decrypt_value(key, value):
    """value value with key
    :param key: secret key to encode the value
    :return: Encrypted on base64 value to encrypt
    with SECRET:: prefix
    """
    secret = hashlib.sha256(key).hexdigest()[0:32]
    if value.startswith('SECRET::'):
        value = value.split('SECRET::')[1]
    msg = base64.b64decode(value)
    msg_nonce = msg[:8]
    ciphertext = msg[8:]
    cipher = ChaCha20.new(key=secret, nonce=msg_nonce)
    return cipher.decrypt(ciphertext)

def filter_prefix(params, prefix):
    """filter parameter defined in a configparser object section.
    the filter is made by parameter name prefix

    eg: if a section contain conn-pasword and the prefix is conn-
    the conn-password will be returned without the conn-prefix
    all the non matching keys in the section will be ignored

    :param params: a configparser section
    :type params: ConfigParser.Section
    :param prefix: the prefix to keep and filter
    :type prefix: str
    :return: a dict containing the filtered values
    :rtype: dict
    """
    return {key.replace(prefix, ''): val for key, val in params.items()
            if key.startswith(prefix)}