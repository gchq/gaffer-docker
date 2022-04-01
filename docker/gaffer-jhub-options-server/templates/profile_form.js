
$(document).ready(() => {

	const toggleSection = (section, show) => {
		$('#' + section + '_section').toggle(!!show)
	}

	const handleProfileSelectionChange = () => {
		const slug = $('input[name=profile]:checked').val()
		console.log('Selected Profile:', slug)

		const profile = PROFILE_FORM_DATA.profiles[slug]
		console.log('Selected Profile:', profile)

		toggleSection('hdfs', profile.enable_hdfs)
		toggleSection('gaffer', profile.enable_gaffer)
		toggleSection('spark', profile.enable_spark)
	}

	const handleNamespaceSelectionChange = () => {
		const currentNamespace = $('#k8s_namespace').val()
		const namespaceConfig = PROFILE_FORM_DATA.namespaces[currentNamespace]

		$('#k8s_service_account').empty().append(new Option('- None -', ''))
		namespaceConfig.serviceAccounts.forEach(serviceAccount => {
			$('#k8s_service_account').append(new Option(serviceAccount.name, serviceAccount.id))
		})

		$('#volume').empty().append(new Option('Create new volume...', ''))
		namespaceConfig.volumes.forEach(volume => {
			$('#volume').append(new Option(
				volume.volumeName,
				volume.id,
				volume.servername == PROFILE_FORM_DATA.servername,
				volume.servername == PROFILE_FORM_DATA.servername
			))
		})

		handleServiceAccountChange()
		handleVolumeChange()
	}

	const handleServiceAccountChange = () => {
		const currentNamespace = $('#k8s_namespace').val()
		const selectedServiceAccount = $('#k8s_service_account').val()

		$('#aws_iam_role_na').show()
		$('#aws_iam_role_info').hide()

		if (selectedServiceAccount != '') {
			const serviceAccountInfo = PROFILE_FORM_DATA.namespaces[currentNamespace].serviceAccounts.filter(sa => sa.id == selectedServiceAccount).pop()
			if (serviceAccountInfo && serviceAccountInfo.iamRole.name) {
				$('#aws_iam_role').text(serviceAccountInfo.iamRole.name)
				$('#aws_iam_role_link').attr('href', 'https://console.aws.amazon.com/iam/home#/roles/' + serviceAccountInfo.iamRole.name)
				$('#aws_iam_role_na').hide()
				$('#aws_iam_role_info').show()
			}
		}
	}

	const handleVolumeChange = () => {
		const selectedVolume = $('#volume').val()

		if (selectedVolume == '') {
			$('#volume_config').show()
		} else {
			$('#volume_config').hide()
		}
	}

	const handleGraphChange = () => {
		const selectedGraph = $('#gaffer_graph').val()

		$('#gaffer_graph_description').text('')
		if (selectedGraph != '') {
			const graphInfo = PROFILE_FORM_DATA.graphs.filter(graph => graph.id == selectedGraph).pop()
			$('#gaffer_graph_description').text(graphInfo.description)
		}
	}

	$('input[type=radio][name=profile]').change(handleProfileSelectionChange)
	$('#k8s_namespace').change(handleNamespaceSelectionChange)
	$('#k8s_service_account').change(handleServiceAccountChange)
	$('#volume').change(handleVolumeChange)
	$('#gaffer_graph').change(handleGraphChange)

	handleProfileSelectionChange()
	handleNamespaceSelectionChange()
	handleGraphChange()
})
